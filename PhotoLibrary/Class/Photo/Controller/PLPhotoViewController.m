//
//  PLPhotoViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoViewController.h"
#import "PLPhotoCell.h"
#import "PLPhotoChannelModel.h"
#import "PLChannelProgramModel.h"
#import "PLPhotoChannelPopupMenuController.h"
#import "PLProgram.h"
#import "PLPhotoNavigationTitleView.h"
#import "PLPhotoBrowser.h"
#import <objc/runtime.h>
#import "PLPaymentViewController.h"
#import "UIScrollView+Refish.h"
static NSString *const kPhotoCellReusableIdentifier = @"PhotoCellReusableIdentifier";
static NSString *const kHeaderReusableIdentifier = @"HeaderReusableIdentifier";
static NSString *const kFooterReusableIdentifier = @"FooterReusableIdentifier";

//static const CGFloat kSectionBorderWidth = 5;
static const CGFloat kPhotoCellInterspace = 5;
static NSString *const kSectionBackgroundColor = @"#503d3c";

@interface PLPhotoViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PLPhotoBrowserDelegate>
{
    /**CollectionView*/
    UICollectionView *_layoutCollectionView;
    UIButton *_floatingButton;
    NSUInteger _currentPage;
    
    PLPhotoNavigationTitleView *_navTitleView;
}
@property (nonatomic,retain) PLPhotoChannelModel *channelModel;
@property (nonatomic,retain) PLChannelProgramModel *channelProgramModel;
/**菜单栏的弹窗*/
@property (nonatomic,retain) PLPhotoChannelPopupMenuController *popupMenuController;

@property (nonatomic,retain) PLPhotoChannel *currentPhotoChannel;
/**在某个栏目上加载数据时存储返回数据的数组*/
@property (nonatomic,retain) NSMutableArray<PLChannelProgram *> *photoPrograms;

@property (nonatomic,retain) PLPhotoBrowser *photoBrowser;

@property (nonatomic) BOOL statusBarHidden;
@end

@implementation PLPhotoViewController
@synthesize currentPhotoChannel = _currentPhotoChannel;

DefineLazyPropertyInitialization(PLPhotoChannelModel, channelModel)
DefineLazyPropertyInitialization(PLChannelProgramModel, channelProgramModel)
DefineLazyPropertyInitialization(NSMutableArray, photoPrograms)

- (instancetype)initWithChannel:(PLPhotoChannel *)channel{

    if (self = [super init]) {
        self.currentPhotoChannel = channel;
    }
    
    return self;

}
#pragma mark -
#pragma mark －－－图片浏览器－－－－
- (PLPhotoBrowser *)photoBrowser {
    if (_photoBrowser) {
        return _photoBrowser;
    }
    
    _photoBrowser = [[PLPhotoBrowser alloc] init];
    _photoBrowser.delegate = self;
    return _photoBrowser;
}
#pragma mark －－－返回状态栏是否被隐藏－－－－
- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}
#pragma mark －－－设置状态栏是否隐藏－－－－
- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

/**获得初始化的菜单栏控制器*/
- (PLPhotoChannelPopupMenuController *)popupMenuController {
    if (_popupMenuController) {
        return _popupMenuController;
    }
    
    @weakify(self);
    _popupMenuController = [[PLPhotoChannelPopupMenuController alloc] init];
    
    _popupMenuController.photoChannelSelAction = ^(PLPhotoChannel *selectedChannel, id sender) {
        @strongify(self);
        
        [self.popupMenuController hide];
        [self payForPayable:selectedChannel withCompletionHandler:^(BOOL success, id obj) {
            if (success) {
                self.currentPhotoChannel = selectedChannel;
                [self.popupMenuController hide];
            }
        }];
    };
    return _popupMenuController;
}
#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 0;
    self.bottomAdBanner = YES;
    [self setCollectionView];
//    [self setChannelBtn];
    
    _navTitleView = [[PLPhotoNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 140, 50)];
    
    /**设置导航栏的标题所在的图片*/
    self.navigationItem.titleView = _navTitleView;
    
    [self addRefresh];
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView:) name:kPaymentNotificationName object:nil];//通知支付成功
    
}

- (void)reloadCollectionView:(NSNotification *)noti{
    
    [_layoutCollectionView reloadData];
    
}
- (void)addRefresh{

    @weakify(self)
    if (self.currentPhotoChannel) {
        [_layoutCollectionView PL_addPullToRefreshWithHandler:^{
            @strongify(self)
            
            [self loadPhotosInChannel:self.currentPhotoChannel withPage:++_currentPage];
        }];
        
    }
//    else {
//        _navTitleView.title = @"图库";
//        [self loadPhotoChannels];//下载频道
//    }
    
    [_layoutCollectionView PL_triggerPullToRefresh];
    
    [_layoutCollectionView PL_addPagingRefreshWithHandler:^{
        
        [self loadPhotosInChannel:self.currentPhotoChannel withPage:++_currentPage];
        
    }];
    


}
- (void)setChannelBtn{

    /**设置设图表面浮动图片*/
    _floatingButton = [[UIButton alloc] init];
    UIImage *flickerImage = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"photo_floating_icon_normal"],
                                                               [UIImage imageNamed:@"photo_floating_icon_highlight"]] duration:0.5];
    [_floatingButton setImage:flickerImage forState:UIControlStateNormal];
    [self.view addSubview:_floatingButton];
    {
        [_floatingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(87, 88.5));
            make.left.bottom.equalTo(_layoutCollectionView).insets(UIEdgeInsetsMake(0, 15, 15, 0));
            
        }];
    }
    
    /**按钮添加点击响应事件*/
    @weakify(self);
    [_floatingButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        UIButton *button = sender;
        
        //坐标参考点转化
        CGPoint point = [self.view convertPoint:CGPointMake(button.frame.origin.x,
                                                            button.frame.origin.y+button.frame.size.height) toView:self.view.window];
        //调用[self popupMenuController]
        
        
        self.popupMenuController.selectedPhotoChannel = self.currentPhotoChannel;
        [self.popupMenuController showInWindowInPosition:point];
    } forControlEvents:UIControlEventTouchUpInside];
    



}
- (void)setCollectionView{

    /**设置layout*/
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kPhotoCellInterspace;
    layout.minimumLineSpacing = kPhotoCellInterspace;
    layout.sectionInset = UIEdgeInsetsMake(kPhotoCellInterspace, kPhotoCellInterspace, kPhotoCellInterspace, kPhotoCellInterspace);
    //    layout.itemSize = ...也可以在代理里面设置单个的item 的size
    
    //滚动方向
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    /**设置collectionView*/
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    _layoutCollectionView.pagingEnabled = NO;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[PLPhotoCell class] forCellWithReuseIdentifier:kPhotoCellReusableIdentifier];
    
    /**设置页眉重用*/
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReusableIdentifier];
    
    /**设置页脚重用*/
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReusableIdentifier];
    
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;

    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, self.adBannerHeight, 0));
            
        }];
    }


}

//#pragma mark －－－下载获取照片的人频道 ...该地方有3个－－－－
////在模型中下载数据，返回的数据已经存入模型中的数组中
//- (void)loadPhotoChannels {
//    @weakify(self);
//    [self.channelModel fetchPhotoChannelsWithCompletionHandler:^(BOOL success, NSArray<PLPhotoChannel *> *channels) {
//
//        
//        @strongify(self);
//        if (!self || !success || channels.count == 0) {
//            return ;
//        }
//
//        /**返回图片模型*/
//        PLPhotoChannel *channelToShow = [channels bk_match:^BOOL(id obj) {
//            if (((PLPhotoChannel *)obj).payAmount.unsignedIntegerValue == 0) {
//                return YES;
//            }
//            return NO;
//        }];
//        
//        if (!channelToShow) {//如果没有返回数据
//            channelToShow = [channels bk_match:^BOOL(id obj) {
//                if ([PLPaymentUtil isPaidForPayable:((PLPhotoChannel *)obj)]) {
//                    return YES;
//                }
//                return NO;
//            }];
//        }
//        
//        if (!channelToShow) {//还是没有返回数据，就弹出提示框
//            [[PLHudManager manager] showHudWithText:@"没有已支付或者免费的图库！"];
//        } else {
//            self.currentPhotoChannel = channelToShow; //程序安装第一次启动进来之后，给当前channel附值，保存到了本地，之后再也不会进来除非，卸载
//        }
//    }];
//}

/**根据图片的频道 获取频道的模型数据*/
- (void)loadPhotosInChannel:(PLPhotoChannel *)photoChannel withPage:(NSUInteger)page {// shouldReload:(BOOL)shouldReload {

    if(self.photoPrograms.count&&self.photoPrograms.count>= self.channelProgramModel.fetchedPrograms.items.integerValue){//刷新到最后一个时候
        
        [[PLHudManager manager] showHudWithText:@"已经翻到最后一页"];
        
        [_layoutCollectionView PL_endPullToRefresh];
        
        [_layoutCollectionView PL_pagingRefreshNoMoreData];
        
        _currentPage--;
        
        return;//结束刷新
    }

    _navTitleView.title = photoChannel.name ?: @"图库";//设定导航栏的标题
    _navTitleView.imageURL = photoChannel.columnImg?[NSURL URLWithString:photoChannel.columnImg]:nil;
    
    if (photoChannel.columnId) {//每个频道都对应一个唯一的columnId
        @weakify(self);
        [self.channelProgramModel fetchProgramsWithColumnId:photoChannel.columnId
                                                     pageNo:page//shouldReload?1:self.photoPrograms.count/kDefaultPageSize+1
                                                   pageSize:kDefaultPageSize
                                          completionHandler:^(BOOL success, PLChannelPrograms *programs)//PLChannelPrograms*programs 返回的是这个频道上的所有的信息，其中有一个属性存的时返回的图片数组，
         {
             @strongify(self);
             if (!self || !success) {
                 return ;
             }
             [_layoutCollectionView PL_endPullToRefresh];
             if(page==1){
                 [self.photoPrograms removeAllObjects];
             }
             //保存下载好的数据到数组，
             [self.photoPrograms addObjectsFromArray:programs.programList];//programs.programList就是返回的所有节目的相关内容
             [self->_layoutCollectionView reloadData];
         }];
    }
}
/**设置当前的图片频道模型*/
- (void)setCurrentPhotoChannel:(PLPhotoChannel *)currentPhotoChannel {
    _currentPhotoChannel = currentPhotoChannel;
    [currentPhotoChannel writeToPersistence];
    
    [self loadPhotosInChannel:currentPhotoChannel withPage:1];
}
/**获取当前的图片频道模型*/
- (PLPhotoChannel *)currentPhotoChannel {
    if (_currentPhotoChannel) {
        return _currentPhotoChannel;
    }
    
    _currentPhotoChannel = [PLPhotoChannel persistentPhotoChannel];
    return _currentPhotoChannel;
}



#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReusableIdentifier forIndexPath:indexPath];
    
    
    if (indexPath.item < self.photoPrograms.count) {
        PLProgram *program = self.photoPrograms[indexPath.item];        
        
        //是否支付过该频道
       BOOL isPayed =  [PLPaymentUtil isPaidForPayable:self.channelProgramModel.fetchedPrograms ];
        cell = [cell setCellWithIndexPath:indexPath andCollectionView:collectionView andModel:program hasTitle:NO hasPayed:isPayed];
        
    } else {
        cell.imageURL = nil;
    }
    
    
    return cell;
}
/**每一个section的item个数*/
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 4;
    return _photoPrograms.count;
}
/**单独定义collectionView的layout的item的size*/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    
        const CGFloat cellHeight = CGRectGetHeight(collectionView.bounds) / 2 - kPhotoCellInterspace*1.5;
        const CGFloat cellWidth = CGRectGetWidth(collectionView.bounds) / 2 - kPhotoCellInterspace * 1.5;
        return CGSizeMake(cellWidth, cellHeight);

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger indexOfAlbum = indexPath.section * 4 + indexPath.row;
    
    if (indexPath.item==0) {
        PLChannelProgram *photoProgram = self.photoPrograms[indexOfAlbum];
        self.photoBrowser.photoAlbum = photoProgram;
        [self.photoBrowser showInView:self.view.window];

    }else{
        @weakify(self);
        DLog(@"----------->%@",self.channelProgramModel.fetchedPrograms.name);
        
        if (indexOfAlbum < self.photoPrograms.count) {
            [self payForPayable:self.channelProgramModel.fetchedPrograms withCompletionHandler:^(BOOL success, id obj) {
                @strongify(self);
                if (success) {//如果支付成功打开图片浏览器
                    PLProgram *photoProgram = self.photoPrograms[indexOfAlbum];
                    self.photoBrowser.photoAlbum = photoProgram;
                    [self.photoBrowser showInView:self.view.window];
                }
            }];
         }
        
     
     }

}
//#pragma mark - 自定义下拉刷新
///**scrollview停止滚动*/
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//
//    NSUInteger currentPage = CGRectGetHeight(scrollView.bounds) > 0 ? scrollView.contentOffset.y / CGRectGetHeight(scrollView.bounds) + 1 : 1;
//    
//    PLChannelPrograms *channelPrograms = self.channelProgramModel.fetchedPrograms;
//    if (currentPage == (channelPrograms.items.unsignedIntegerValue+3) / 4) {
//        return ;
//    }
//    
////    if (![PLPaymentUtil isPaidForPayable:channelPrograms]) {
////        return ;
////    }
//    
//    NSUInteger pagesForOneRequest = channelPrograms.pageSize.unsignedIntegerValue / 4;//分页
//    NSUInteger loadedPages = channelPrograms.page.unsignedIntegerValue * pagesForOneRequest;
//    if (currentPage % pagesForOneRequest == 0 && loadedPages == currentPage) {//下载下一页的图片
//        [self loadPhotosInChannel:self.currentPhotoChannel withPage:channelPrograms.page.unsignedIntegerValue+1];
//    }
//}
///**scrollview开始减速*/
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    
//    NSUInteger currentPage = CGRectGetHeight(scrollView.bounds) > 0 ? scrollView.contentOffset.y / CGRectGetHeight(scrollView.bounds) + 1 : 1;
//    
//    PLChannelPrograms *channelPrograms = self.channelProgramModel.fetchedPrograms;
////    if (currentPage == kAutoPopupPaymentInScrollingPage) {
////        [self payForPayable:channelPrograms withCompletionHandler:nil];
////    }
//    
//    if (currentPage == (channelPrograms.items.unsignedIntegerValue+3) / 4) {
//        [[PLHudManager manager] showHudWithText:@"已经翻到最后一页"];
//    }
//}

#pragma mark - PLPhotoBrowserDelegate


- (BOOL)photoBrowser:(PLPhotoBrowser *)photoBrowser shouldDisplayPhotoAtIndex:(NSUInteger)index{

    id<PLPayable> payable = self.channelProgramModel.fetchedPrograms;
    
    //点击锁后的回调
    @weakify(self)
    photoBrowser.payAction = ^(id sender){
        @strongify(self)
        
        [self payForPayable:payable];
        
    };
    
    return [PLPaymentUtil isPaidForPayable:payable];
    
}
- (void)payForPayable:(id<PLPayable>)payable{
    
    @weakify(self);
    [self payForPayable:payable withBeginAction:^(id obj) {
        @strongify(self);
        [self.photoBrowser hide];
    } completionHandler:^(BOOL success, id obj) {
        if (success) {
            [self.photoBrowser showInView:self.view.window];
        }
    }];
    
}

- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser willEndDisplayingAlbum:(PLProgram *)album {
    self.statusBarHidden = NO;
    DLog(@"-----------------------------");
    
}

- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser didDisplayAlbum:(PLProgram *)album {
    self.statusBarHidden = YES;
    
    [PLStatistics statViewAlbumPhotos:album];//在友盟中记录下来
}
@end
