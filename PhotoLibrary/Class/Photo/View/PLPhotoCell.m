//
//  PLPhotoCell.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoCell.h"
#import "UIImage+ZFFilter.h"

static const CGFloat kImageOffset = 5;

@interface PLPhotoCell ()
@property (nonatomic,retain,readonly) UIImageView *imageView;
@property (nonatomic,retain,readonly) UIImageView *backgroundImageView;
@property (nonatomic,strong) UIView *effectView;
@end

@implementation PLPhotoCell

@synthesize imageView = _imageView;
@synthesize backgroundImageView = _backgroundImageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_album_background"]];
        _backgroundImageView.hidden = YES;
        [self addSubview:_backgroundImageView];
        {
            [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).insets(UIEdgeInsetsMake(kImageOffset/2, kImageOffset/2, 0, 0));
            }];
        }
        
        [self addImageView];

    }
    return self;
}

- (void)addImageView{

    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.layer.cornerRadius = 4;
    
    _imageView.layer.borderWidth = 0.5;
    _imageView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1].CGColor;

    [self addSubview:_imageView];
    {
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, kImageOffset, kImageOffset));
        }];
    }

}

- (instancetype)setCellWithIndexPath:(NSIndexPath *)indexpath andCollectionView:(UICollectionView *)collectionView andModel:(PLProgram *)model{

    if (indexpath.item==0) {
        self.effectView.hidden = YES;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg]];

    }else{
        self.effectView.hidden = NO;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self BlurWithImageView:nil];
        }];
    
    }
    
    
    
    return self;
}
#pragma mark - 设置cell的图片
- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    _backgroundImageView.hidden = imageURL == nil;
    _imageView.layer.borderWidth = imageURL == nil ? 0 : 0.5;

    [self.imageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self BlurWithImageView:nil];
    }];
    

}

- (void)BlurWithImageViewForiOS7:(UIImageView*)imageView{
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.contentView.bounds];
       toolbar.tag = 10;
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        self.effectView = toolbar;
        [self.imageView addSubview:toolbar];
        toolbar.alpha = 0.8;
}
- (void)BlurWithImageView:(UIImageView *)imageview{

    for (UIView*view in self.imageView.subviews) {
        if (view.tag==10) {
            [view removeFromSuperview];
            break;
        }
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue>=8.0) {
        /**  毛玻璃特效类型
         *  UIBlurEffectStyleExtraLight,
         *  UIBlurEffectStyleLight,
         *  UIBlurEffectStyleDark
         */
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        
        //  毛玻璃视图
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.effectView = effectView;
        effectView.tag = 10;
        //添加到要有毛玻璃特效的控件中
        effectView.frame = self.imageView.bounds;
        [self.imageView addSubview:effectView];
        
        //设置模糊透明度
        effectView.alpha = 0.8f;
    }else{
        [self BlurWithImageViewForiOS7:nil];
    
    }
    
}
@end
