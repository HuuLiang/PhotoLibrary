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

static NSString *const kVideoCellReusableIdentifier = @"VideoCellReusableIdentifier";
static const CGFloat kInteritemSpacing = 2;
static const CGFloat kLineSpacing = kInteritemSpacing;

@interface PLVideoViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
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
    [self.view addSubview:_collectionView];
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self loadVideosWithReloadFlag:YES];
}

- (void)loadVideosWithReloadFlag:(BOOL)shouldReload {
    @weakify(self);
    NSUInteger loadPage = shouldReload ? 1 : self.videoModel.fetchedVideos.page.unsignedIntegerValue + 1;
    [self.videoModel fetchVideosWithPageNo:loadPage completionHandler:^(BOOL success, PLVideos *videos) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (success) {
            if (shouldReload) {
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
    return CGSizeMake(cellHeight*0.7, cellHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLVideo *video = self.videos[indexPath.row];
    [self switchToPlayProgram:video];
}
@end
