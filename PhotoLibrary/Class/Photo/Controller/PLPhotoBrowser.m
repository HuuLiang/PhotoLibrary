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
/**处理有栏目的照片的*/
#import "PLChannelProgramModel.h"
/**支付弹窗控制器*/
#import "PLPaymentViewController.h"
#import "PLPhotoViewController.h"


#import "MWPhotoBrowser.h"
static const CGFloat kViewFadeAnimationDuration = 0.3;

@interface PLPhotoBrowser () <MWPhotoBrowserDelegate>
{
    UILabel *_titleLabel;
    BOOL _isLeftScroll;
}
/**第三方MWPhotoBrowser*/
@property (nonatomic,retain) MWPhotoBrowser *photoBrowser;

@property (nonatomic,retain) PLProgramUrlModel *urlModel;

@property (nonatomic,retain) NSArray<MWPhoto *> *photos;

@property (nonatomic,strong) NSMutableArray<MWPhoto *> *Allphoto;


@property (nonatomic,strong) PLChannelProgramModel *channelProgramModel;

@property (nonatomic,strong) PLPaymentViewController *paymentVC;


@end

@implementation PLPhotoBrowser//继承baseVC

DefineLazyPropertyInitialization(PLProgramUrlModel, urlModel)


DefineLazyPropertyInitialization(PLChannelProgramModel, channelProgramModel)

DefineLazyPropertyInitialization(NSMutableArray, Allphoto)

- (instancetype)initWithAlbum:(PLProgram *)album {
    if (self) {
        _photoAlbum = album;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _isLeftScroll = NO;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeData) name:@"removeData" object:nil];
    
}

- (void)reloadBrowser{
    [self.photoBrowser reloadData];
}
- (void)removeData{
    
    [self.Allphoto removeAllObjects];
    self.currentPhotoAlbumIndex=0;
}

- (void)dealloc{
    //    [_photoBrowser.pagingScrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_photoBrowser.pagingScrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.Allphoto.count != 0) {
        [self.Allphoto removeAllObjects];
    }
    
}
#pragma mark - 照片浏览器即将显示的时候下载数据
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.photoBrowser) {//初始化专门播放图片的控制器
        self.photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        
        //        self.photoBrowser.displayActionButton = NO;
        
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
        [_photoBrowser.pagingScrollView addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew) context:nil];
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
        
        if (![PLUtil isPictureVip]) {
            NSMutableArray <MWPhoto *> *photo = [NSMutableArray array];
            
            for (int i = 0; i<3; ++i) {
                [photo addObject:photos[i]];
            }
            self.photos = photo;
             [self.Allphoto removeAllObjects];
            
        }else{
            
            self.photos = photos;//获取数据后的模型数组，里面装的全是URL
        }
        
       
        
        [self.Allphoto addObjectsFromArray:self->_photos];
        
        
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
    
    UIView *hudView = [PLHudManager manager].hudView;
    if ([view.subviews containsObject:hudView]) {
        [view insertSubview:self.view belowSubview:[PLHudManager manager].hudView];
    }else {
        [view addSubview:self.view];//PhotoVC.View
        
    }
    
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

- (void)setPhotos:(NSArray<MWPhoto *> *)photos {
    _photos = photos;
    
    _titleLabel.hidden = photos.count == 0;
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {

    return   self.Allphoto.count;
}


- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    BOOL isPayed = [PLUtil isPictureVip];
    if ([self.delegate respondsToSelector:@selector(photoBrowser:shouldDisplayPhotoAtIndex:)]) {
        [self.delegate photoBrowser:self shouldDisplayPhotoAtIndex:index];
    }
    
    if (index>2) {
        
        if (isPayed) {
            self.Allphoto[index].isLocked = NO;
            if (index==self.Allphoto.count-1) {//相册最后一张
                
                self.currentPhotoAlbumIndex++;
                
                [self.channelAlbum enumerateObjectsUsingBlock:^(PLProgram *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if (idx == self.currentPhotoAlbumIndex) {
                        self.photoAlbum = obj;
                        *stop = YES;
                    }
                }];
                
                
                if (self.channelAlbum.count>=self.currentPhotoAlbumIndex+1) {//来这里表明是最后一个相册的最后一张
                    [self loadAlbumUrls];
                }else{
                    
                    return self.Allphoto[index];
                }
                
            }
            
        }else{
            self.Allphoto[index].isLocked = YES;
            
            @weakify(self)
            self.Allphoto[index].tapLockAction = ^(id sender) {
                @strongify(self)
                
                self.payAction(sender);
                
            };
            
        }
        
    }
    
    
    return self.Allphoto[index];
    
    //
    //        if (isPayed) {
    //            self.photos[index].isLocked = NO;
    //        }else{
    //            self.photos[index].isLocked = YES;
    //        }
    //
    //        @weakify(self)
    //        self.photos[index].tapLockAction = ^(id sender) {
    //            @strongify(self)
    //
    //            DLog(@"%@",self.photos[index]);
    //            self.payAction(sender);
    //            
    //        };
    //    return self.photos[index];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    
    if ([PLUtil isPictureVip]) {
        
        _titleLabel.text = [NSString stringWithFormat:@"%lu / %ld",index+1,(unsigned long)self.Allphoto.count];
    } else {
        _titleLabel.text = [NSString stringWithFormat:@"%lu / %@",index+1,self.pictureCount];
    
    }
    if (self.payed) {
        
    }else {
        if (index == 2){
            
            if (self.payAction) {
                self.payAction(nil);
                
            }
//            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom)];
//            [_photoBrowser.pagingScrollView addGestureRecognizer:panRecognizer];
        }
        
        
    }
}

//- (void)handlePanFrom {
//    
//    if (!self.payed) {
//        if (self.payAction) {
//            self.payAction(nil);
//        }
//    }
//    
//}


//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser willDisplayPhoto:(id<MWPhoto>)photo atIndex:(NSUInteger)index inUnderlyingScrollView:(UIScrollView *)scrollView{
//    
//    
//    
//}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    //    if ((CGPoint)object)
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView*)object;
        
        if (scrollView.contentOffset.x == kScreenWidth*2+41) {
            if (![PLUtil isPictureVip]) {
                if (self.payAction) {
                    self.payAction(nil);
                }  
            }
        }
    }
}
//
//





@end
