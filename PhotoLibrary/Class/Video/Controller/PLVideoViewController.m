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
#import "UIScrollView+Refish.h"
static NSString *const kVideoCellReusableIdentifier = @"VideoCellReusableIdentifier";
static const CGFloat kInteritemSpacing = 2;
static const CGFloat kLineSpacing = kInteritemSpacing;

@interface PLVideoViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    NSUInteger _currentPage;
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
    _currentPage = 1;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kInteritemSpacing;
    layout.minimumLineSpacing = kLineSpacing;
    layout.sectionInset = UIEdgeInsetsMake(kLineSpacing, kLineSpacing, kLineSpacing, kLineSpacing);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[PLVideoCell class] forCellWithReuseIdentifier:kVideoCellReusableIdentifier];
    _collectionView.pagingEnabled = NO;
    [self.view addSubview:_collectionView];
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
//    [self loadVideosWithPage:_currentPage];
    
    @weakify(self)
    [_collectionView PL_addPullToRefreshWithHandler:^{
        @strongify(self)
         [self loadVideosWithPage:_currentPage++];
    }];
   
    [_collectionView PL_triggerPullToRefresh];
    
    [_collectionView PL_addPagingRefreshWithHandler:^{
        
        [self loadVideosWithPage:_currentPage++];

    }];
}

- (void)loadVideosWithPage:(NSUInteger)page {
    
    
    if(self.videos.count&&self.videos.count>= self.videoModel.fetchedVideos.items.integerValue){//刷新到最后一个时候
        
        [[PLHudManager manager] showHudWithText:@"已经翻到最后一页"];
        
        [_collectionView PL_endPullToRefresh];
        
        [_collectionView PL_pagingRefreshNoMoreData];
        
        _currentPage--;
        
        return;//结束刷新
    }

    
    @weakify(self);
//    NSUInteger loadPage = shouldReload ? 1 : self.videoModel.fetchedVideos.page.unsignedIntegerValue + 1;
    [self.videoModel fetchVideosWithPageNo:page completionHandler:^(BOOL success, PLVideos *videos) {
        @strongify(self);
        if (!self) {
            return ;
        }
        [_collectionView PL_endPullToRefresh];
        if (success) {
//            if (page == 1) {
//                [self.videos removeAllObjects];
//            }
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
    const CGFloat cellHeight = (CGRectGetHeight(collectionView.bounds) - kLineSpacing * 3) / 2;
    const CGFloat cellWidth = (CGRectGetWidth(collectionView.bounds) - kLineSpacing * 3) / 2;
    return CGSizeMake(cellWidth, cellHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    
//
//    PLVideo *video = self.videos[indexPath.row];
//    [self playVideo:video];

    id<PLPayable> payable = self.videoModel.fetchedVideos;
    [self payForPayable:payable withCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (success) {
            PLVideo *video = self.videos[indexPath.row];
            [self playVideo:video];
        }
    }];
}
//#pragma mark - scrollViewDelegate
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    
//    NSUInteger currentPage = CGRectGetHeight(scrollView.bounds) > 0 ? lround(scrollView.contentOffset.y / CGRectGetHeight(scrollView.bounds)) + 1 : 1;
//    
//    PLVideos *videos = self.videoModel.fetchedVideos;
//    if (currentPage == (videos.items.unsignedIntegerValue+3) / 4) {
//        return ;
//    }
//    
//    NSUInteger pagesForOneRequest = videos.pageSize.unsignedIntegerValue / 4;
//    NSUInteger loadedPages = videos.page.unsignedIntegerValue * pagesForOneRequest;
//    if (currentPage % pagesForOneRequest == 0 && loadedPages == currentPage) {
//        [self loadVideosWithPage:videos.page.unsignedIntegerValue+1];
//    }
//}
//
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    NSUInteger currentPage = CGRectGetWidth(scrollView.bounds) > 0 ? lround(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds)) + 1 : 1;
//    
//    PLVideos *videos = self.videoModel.fetchedVideos;
//    if (currentPage == (videos.items.unsignedIntegerValue+3) / 4) {
//        [[PLHudManager manager] showHudWithText:@"已经翻到最后一页"];
//    }
//}

@end
