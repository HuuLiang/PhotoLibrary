//
//  PLFreeViewController.m
//  PhotoLibrary
//
//  Created by ZF on 16/2/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLFreeViewController.h"

#import "PLCollectionViewLayout.h"

/**自定义的cell*/
#import "FreePhotoCell.h"

/**添加新分类*/
#import "UIScrollView+Refish.h"

/**照片浏览器*/
#import "PLPhotoBrowser.h"
/**免费的获取图片模型*/
#import "PLFreePhotoModel.h"
/**cell返回的模型*/
#import "PLFreePhoto.h"

static NSString *const kFreePhotoCellReusableIdentifier = @"FreePhotoCellReusableIdentifier";

@interface PLFreeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,PLfreeCollectionViewDelegate,PLPhotoBrowserDelegate>

{
   UICollectionView *_layoutCollectionView;
    NSUInteger _currentPage;
}
@property (nonatomic,strong) PLFreePhotoModel *freePhotoModel;
@property (nonatomic,strong) PLFreePhoto *freePhoto;

@property (nonatomic,strong) NSMutableArray<PLFreePhoto *> *freePhotoArray;
@property (nonatomic,strong) NSMutableArray<PLFreePhotoItem*>*freePhotoItemArray;

@property (nonatomic,strong) PLPhotoBrowser *photoBrowser;
@property (nonatomic,assign) BOOL statusBarHidden;
@end


@implementation PLFreeViewController

/**一定要先初始化模型*/
//--用到下面的几个
DefineLazyPropertyInitialization(PLFreePhotoModel, freePhotoModel)
DefineLazyPropertyInitialization(PLFreePhoto, freePhoto)
DefineLazyPropertyInitialization(NSMutableArray, freePhotoArray)
DefineLazyPropertyInitialization(NSMutableArray, freePhotoItemArray)
//--

#pragma mark -
#pragma mark 图片浏览器
- (PLPhotoBrowser *)photoBrowser {
    if (_photoBrowser) {
        return _photoBrowser;
    }
    
    _photoBrowser = [[PLPhotoBrowser alloc] init];
    
    _photoBrowser.fetchedData = self.freePhotoModel.freeFetchedPhoto;
    _photoBrowser.delegate = self;
    return _photoBrowser;
}
#pragma mark 返回状态栏是否被隐藏
- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}
#pragma mark 设置状态栏是否隐藏
- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     _currentPage = 1;
    
    /**设置自定义的collectionView*/
    [self setCollectionView];
    
}

#pragma mark - 设置CollectionView

- (void)setCollectionView
{
    PLCollectionViewLayout *layout = [[PLCollectionViewLayout alloc] init];
    
    layout.interItemSpacing = 8;
    
    layout.delegate = self;
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    _layoutCollectionView.backgroundColor = [UIColor whiteColor];
    
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[FreePhotoCell class] forCellWithReuseIdentifier:kFreePhotoCellReusableIdentifier];
    
    [self.view addSubview:_layoutCollectionView];
    
    /**自动布局*/
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(layout.interItemSpacing, layout.interItemSpacing, layout.interItemSpacing, layout.interItemSpacing));
        }];
    }

 /**关于刷新*/
    @weakify(self);//下拉刷新
    [_layoutCollectionView PL_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadFreePhotoWithPageNo:_currentPage++];
    }];
        [_layoutCollectionView PL_triggerPullToRefresh];
    
    [_layoutCollectionView PL_addPagingRefreshWithHandler:^{
        @strongify(self);
    
        [self loadFreePhotoWithPageNo:_currentPage+1];
    }];
}

#pragma mark - 下载数据
/**用参数为pageNo的去下载数据*/
- (void)loadFreePhotoWithPageNo:(NSUInteger)pageNo {
    

    if(self.freePhotoItemArray.count&&self.freePhotoItemArray.count>= self.freePhotoModel.freeFetchedPhoto.items.integerValue){//刷新到最后一个时候
        
        [[PLHudManager manager] showHudWithText:@"已经翻到最后一页"];
        
        [_layoutCollectionView PL_endPullToRefresh];
        
        [_layoutCollectionView PL_pagingRefreshNoMoreData];
        
        _currentPage--;
        
        return;//结束刷新
    }

    @weakify(self);
    
    [self.freePhotoModel fetchFreePhotosWithPageNo:pageNo completionHandler:^(BOOL success, PLFreePhoto *freePhoto) {//PLFreePhoto *freePhoto回调的单个cell上的节目
        
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [_layoutCollectionView PL_endPullToRefresh];
        if (success) {
            
            [self.freePhotoItemArray addObjectsFromArray:freePhoto.programList];//里面放的是节目属性
            
            [self->_layoutCollectionView reloadData];
        }
    }];

}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FreePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFreePhotoCellReusableIdentifier forIndexPath:indexPath];
    
    /**用模型中的属性设置cell中的图片*/
    
    if(indexPath.item<self.freePhotoItemArray.count){//设置单个cell上的图片
    
        PLFreePhotoItem *photoItem = _freePhotoItemArray[indexPath.item];
//        cell.imageURL = [NSURL URLWithString:photoItem.coverImg];
        BOOL hasIcon = YES;
        if (photoItem.type.integerValue==3) {//是广告
            hasIcon = NO;
        }
        [cell setImageURL:[NSURL URLWithString:photoItem.coverImg] withFreeIcon:hasIcon];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.freePhotoItemArray.count) {

        PLFreePhotoItem *freePhotoItem = self.freePhotoItemArray[indexPath.item];
        if(freePhotoItem.type.integerValue == 3){//点击广告后自动安装
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:freePhotoItem.videoUrl]];
            return;
        }
        self.photoBrowser.photoAlbum = freePhotoItem;//这个就是PLProgram这个类
        
        [self.photoBrowser showInView:self.view.window];
    }
    
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.freePhotoItemArray.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;

}

#pragma mark - PLPhotoBrowserDelegate

- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser willEndDisplayingAlbum:(PLProgram *)album {
    self.statusBarHidden = NO;
}

- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser didDisplayAlbum:(PLProgram *)album {
    self.statusBarHidden = YES;
    
    [PLStatistics statViewAlbumPhotos:album];//在友盟中记录下来
}

#pragma mark - PLfreeCollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout hasAdBannerForItem:(NSUInteger)item{
    
    //判断item是否有广告。
    PLFreePhotoItem *photoItem = _freePhotoItemArray[item];
    if (photoItem.type.integerValue == 3) {//有广告
        return YES;
    }else return NO;

}
@end
