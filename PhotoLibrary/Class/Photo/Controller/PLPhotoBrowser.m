//
//  PLPhotoBrowser.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/5.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoBrowser.h"
#import "PLProgramUrlModel.h"
#import <MWPhotoBrowser.h>

static const CGFloat kViewFadeAnimationDuration = 0.3;

@interface PLPhotoBrowser () <MWPhotoBrowserDelegate>
{
    UILabel *_titleLabel;
}
@property (nonatomic,retain) MWPhotoBrowser *photoBrowser;

@property (nonatomic,retain) PLProgramUrlModel *urlModel;
@property (nonatomic,retain) NSArray<MWPhoto *> *photos;
@end

@implementation PLPhotoBrowser

DefineLazyPropertyInitialization(PLProgramUrlModel, urlModel)

- (instancetype)initWithAlbum:(PLProgram *)album {
    if (self) {
        _photoAlbum = album;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.photoBrowser) {
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
    
    self.view.pl_loadingView.backgroundColor = [UIColor blackColor];
    self.view.pl_loadingIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self.view pl_beginLoading];
    [self loadAlbumUrls];
}

- (void)loadAlbumUrls {
    if (!self.photoAlbum.programId) {
        return ;
    }
    
    @weakify(self);
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
        self.photos = photos;
        [self.photoBrowser reloadData];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.photoBrowser willMoveToParentViewController:nil];
    [self.photoBrowser removeFromParentViewController];
    [self.photoBrowser.view removeFromSuperview];
    self.photoBrowser = nil;
}

- (void)showInView:(UIView *)view {
    if ([view.subviews containsObject:self.view]) {
        return ;
    }
    
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    if ([view.subviews containsObject:[PLHudManager manager].hudView]) {
        [view insertSubview:self.view belowSubview:[PLHudManager manager].hudView];
    } else {
        [view addSubview:self.view];
    }
    
    [UIView animateWithDuration:kViewFadeAnimationDuration animations:^{
        self.view.alpha = 1;
    }];
}

- (void)hide {
    if (self.view.superview) {
        [UIView animateWithDuration:kViewFadeAnimationDuration animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }
}

- (void)setPhotoAlbum:(PLProgram *)photoAlbum {
    _photoAlbum = photoAlbum;
    [self loadAlbumUrls];
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
    return self.photos[index];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    _titleLabel.text = [NSString stringWithFormat:@"%ld / %ld",index+1,self.photos.count];
}
@end
