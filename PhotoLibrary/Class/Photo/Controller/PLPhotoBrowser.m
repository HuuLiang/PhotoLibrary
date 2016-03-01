//
//  PLPhotoBrowser.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/5.
//  Copyright © 2015年 iqu8. All rights reserved.
//  处理点击首页item后的处理图片的控制器

#import "PLPhotoBrowser.h"
#import "PLProgramUrlModel.h"
/**处理免费照片的*/
#import "PLFreePhotoModel.h"
/**处理有栏目的照片的*/
#import "PLChannelProgramModel.h"
/**支付弹窗控制器*/
#import "PLPaymentViewController.h"
#import "PLPhotoViewController.h"


#import <MWPhotoBrowser.h>
#import "PLFreeViewController.h"
static const CGFloat kViewFadeAnimationDuration = 0.3;

@interface PLPhotoBrowser () <MWPhotoBrowserDelegate,PLPaymentViewControllerDelegate>
{
    UILabel *_titleLabel;
}
/**第三方MWPhotoBrowser*/
@property (nonatomic,retain) MWPhotoBrowser *photoBrowser;

@property (nonatomic,retain) PLProgramUrlModel *urlModel;

@property (nonatomic,retain) NSArray<MWPhoto *> *photos;

@property (nonatomic,strong) PLFreePhotoModel *freePhotoModel;

@property (nonatomic,strong) PLChannelProgramModel *channelProgramModel;

@property (nonatomic,strong) PLPaymentViewController *paymentVC;
@property (nonatomic,assign) BOOL isSuccess;
@end

@implementation PLPhotoBrowser//继承baseVC

DefineLazyPropertyInitialization(PLProgramUrlModel, urlModel)

DefineLazyPropertyInitialization(PLFreePhotoModel, freePhotoModel)

DefineLazyPropertyInitialization(PLChannelProgramModel, channelProgramModel)

- (instancetype)initWithAlbum:(PLProgram *)album {
    if (self) {
        _photoAlbum = album;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isSuccess = NO;
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:_titleLabel];
    {
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-50);
        }];
    }
    
    @weakify(self);
    [self.view bk_whenTapped:^{
        @strongify(self);
        [self hide];
    }];
}

#pragma mark - 照片浏览器即将显示的时候下载数据
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.photoBrowser) {//初始化专门播放图片的控制器
        self.photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
       
        self.photoBrowser.displayActionButton = NO;
        
        [self addChildViewController:self.photoBrowser];
        self.photoBrowser.view.frame = self.view.bounds;
        [self.view insertSubview:self.photoBrowser.view belowSubview:_titleLabel];
        {
            [self.photoBrowser.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
        [self.photoBrowser didMoveToParentViewController:self];
    }
    //设置数据加载时的界面状态
    self.view.pl_loadingView.backgroundColor = [UIColor blackColor];
    self.view.pl_loadingIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self.view pl_beginLoading];//开始转圈
    [self loadAlbumUrls];//下载图片数据
}
#pragma mark - 下载数据
- (void)loadAlbumUrls {
    if (!self.photoAlbum.programId) {
        return ;
    }
    
    @weakify(self);//self.urlModel是PLProgramUrlModel的对象，
    [self.urlModel fetchUrlListWithProgramId:self.photoAlbum.programId pageNo:1 pageSize:1000 completionHandler:^(BOOL success, NSArray<PLProgramUrl *> *urlList) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self.view pl_endLoading];
        
        NSMutableArray<MWPhoto *> *photos = [NSMutableArray array];
        [urlList enumerateObjectsUsingBlock:^(PLProgramUrl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:obj.url]]];
            }
        }];
        self.photos = photos;//获取数据后的模型数组，里面装的全是URL
        
        [self.photoBrowser reloadData];
    }];
}

#pragma mark - 视图即将消失时候移除photoBrowser控制器
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.photoBrowser willMoveToParentViewController:nil];
    [self.photoBrowser removeFromParentViewController];
    [self.photoBrowser.view removeFromSuperview];
    self.photoBrowser = nil;
}

/**在哪个视图上显示*/
- (void)showInView:(UIView *)view {
    if ([view.subviews containsObject:self.view]) {
        return ;
    }
    
    self.view.frame = view.bounds;
    self.view.alpha = 0;
//
//    if ([view.subviews containsObject:[PLHudManager manager].hudView]) {
//        [view insertSubview:self.view belowSubview:[PLHudManager manager].hudView];
//    }else {
        [view addSubview:self.view];//PhotoVC.View
        
//    }
    
    [UIView animateWithDuration:kViewFadeAnimationDuration animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:didDisplayAlbum:)]) {//点击后记录一下访问
            [self.delegate photoBrowser:self didDisplayAlbum:self.photoAlbum];
        }
    }];
}

#pragma mark - 隐藏photoBrowser控制器视图，实际上是移除,

- (void)hide {
    if (self.view.superview) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:willEndDisplayingAlbum:)]) {
            [self.delegate photoBrowser:self willEndDisplayingAlbum:self.photoAlbum];
        }
        
        [UIView animateWithDuration:kViewFadeAnimationDuration animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }
}
#pragma mark - PLPaymentViewControllerDelegate
- (void)dismissViewController{

}
- (void)setPhotos:(NSArray<MWPhoto *> *)photos {
    _photos = photos;
    
    _titleLabel.hidden = photos.count == 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;

}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    

    if ([self.delegate isKindOfClass:[PLFreeViewController class]]&&index>=3){
        
        id<PLPayable>payable = self.fetchedData;
        
        [self payForPayable:payable withCompletionHandler:^(BOOL success) {
            
            _isSuccess = success;
            
        }];
    }
    if (index>=3&&!_isSuccess) {
        
    [self.photoBrowser showPreviousPhotoAnimated:YES];
        
     return nil;

    }else{
        return self.photos[index];
    }
    
}

#warning 如果要查看图片数组时候，当浏览图片到第二页时候，弹出支付界面可以在这个地方设置

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    
    _titleLabel.text = [NSString stringWithFormat:@"%ld / %ld",index+1,self.photos.count];

    if ([self.delegate isKindOfClass:[PLFreeViewController class]]&&index>=2) {
        
        id<PLPayable>payable = self.fetchedData;
        
        [self payForPayable:payable withCompletionHandler:^(BOOL success) {
            if (success) {
                //如果没有支付，弹出支付界面
            }
        }];
     
    }
//    else if ([self.delegate isKindOfClass:[PLPhotoViewController class]]&&index>=2){
//        
////        id<PLPayable>payable = self.channelProgramModel.fetchedPrograms;
//        id<PLPayable>payable = self.fetchedData;//不能用上面的原因是因为，从模型中获取的数据没有给PhotoBrowser。
//        [self payForPayable:payable withCompletionHandler:^(BOOL success) {
//        }];
//
//    }
}
@end
