//
//  PLVideoViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLVideoViewController.h"
#import "PLVideoModel.h"
#import "PLVideoCell.h"
//#import "ODRefreshControl.h"

static NSString *const kVideoCellReusableIdentifier = @"VideoCellReusableIdentifier";
static const CGFloat kInteritemSpacing = 2;
static const CGFloat kLineSpacing = kInteritemSpacing;

@interface PLVideoViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
//    ODRefreshControl *_refreshControl;
}
@property (nonatomic,retain) PLVideoModel *videoModel;
@property (nonatomic,retain) NSMutableArray *videos;
@end

@implementation PLVideoViewController

DefineLazyPropertyInitialization(PLVideoModel, videoModel)
DefineLazyPropertyInitialization(NSMutableArray, videos)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kInteritemSpacing;
    layout.minimumLineSpacing = kLineSpacing;
    layout.sectionInset = UIEdgeInsetsMake(kLineSpacing, kLineSpacing, kLineSpacing, kLineSpacing);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[PLVideoCell class] forCellWithReuseIdentifier:kVideoCellReusableIdentifier];
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self loadVideosWithPage:1];
    
//    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_collectionView];
//    [_refreshControl bk_addEventHandler:^(id sender) {
//        
//    } forControlEvents:UIControlEventValueChanged];
}

- (void)loadVideosWithPage:(NSUInteger)page {
    @weakify(self);
//    NSUInteger loadPage = shouldReload ? 1 : self.videoModel.fetchedVideos.page.unsignedIntegerValue + 1;
    [self.videoModel fetchVideosWithPageNo:page completionHandler:^(BOOL success, PLVideos *videos) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (success) {
            if (page == 1) {
                [self.videos removeAllObjects];
            }
            [self.videos addObjectsFromArray:videos.programList];
            [self->_collectionView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellReusableIdentifier forIndexPath:indexPath];
    cell.video = self.videos[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat cellHeight = (CGRectGetHeight(self.view.bounds) - kLineSpacing * 3) / 2;
    const CGFloat cellWidth = (CGRectGetWidth(self.view.bounds) - kLineSpacing * 3) / 2;
    return CGSizeMake(cellWidth, cellHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    id<PLPayable> payable = self.videoModel.fetchedVideos;
    [self payForPayable:payable withCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (success) {
            PLVideo *video = self.videos[indexPath.row];
            [self playVideo:video];
        }
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger currentPage = CGRectGetWidth(scrollView.bounds) > 0 ? lround(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds)) + 1 : 1;
    
    PLVideos *videos = self.videoModel.fetchedVideos;
    if (currentPage == (videos.items.unsignedIntegerValue+3) / 4) {
        return ;
    }
    
    NSUInteger pagesForOneRequest = videos.pageSize.unsignedIntegerValue / 4;
    NSUInteger loadedPages = videos.page.unsignedIntegerValue * pagesForOneRequest;
    if (currentPage % pagesForOneRequest == 0 && loadedPages == currentPage) {
        [self loadVideosWithPage:videos.page.unsignedIntegerValue+1];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSUInteger currentPage = CGRectGetWidth(scrollView.bounds) > 0 ? lround(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds)) + 1 : 1;
    
    PLVideos *videos = self.videoModel.fetchedVideos;
    if (currentPage == (videos.items.unsignedIntegerValue+3) / 4) {
        [[PLHudManager manager] showHudWithText:@"已经翻到最后一页"];
    }
}

@end
