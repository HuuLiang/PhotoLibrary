//
//  PLPhotoCell.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoCell.h"
#import "UIImage+ZFFilter.h"
#import "UIImage+Blur.h"
#import "PLProgram.h"
#import <SDWebImage/SDWebImageDownloader.h>
static const CGFloat kImageOffset = 5;

@interface PLPhotoCell ()
{
    UILabel *_titleLabel;
    
    
}
@property (nonatomic,retain,readonly) UIImageView *imageView;
@property (nonatomic,retain,readonly) UIImageView *backgroundImageView;
@property (nonatomic,strong) UIView *effectView;
//@property (nonatomic,strong) UIImageView *coverFlurView;
@end

@implementation PLPhotoCell

@synthesize imageView = _imageView;
@synthesize backgroundImageView = _backgroundImageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_album_background"]];
        _backgroundImageView.hidden = NO;
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
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor grayColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:20];
    
    [_imageView addSubview:_titleLabel];
    _titleLabel.hidden = YES;
    
    //    self.coverFlurView =  [[UIImageView alloc] init];
    //    self.coverFlurView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
    //    
    //    _coverFlurView.hidden = NO;
    //
    //     [_imageView addSubview:self.coverFlurView];
    //    [self.coverFlurView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.edges.equalTo(_imageView);
    //    }];
//    _imageView.image = [UIImage imageNamed:@"photo_album_background"];
//
//    [self BlurWithImageView:_imageView];
    
    [self addSubview:_imageView];
    {
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, kImageOffset, kImageOffset));
        }];
    }
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_imageView);
        make.height.mas_equalTo(20);
    }];
    
}

- (instancetype)setChannelCellWithIndexPath:(NSIndexPath *)indexpath andCollectionView:(UICollectionView *)collectionView andModel:(PLPhotoChannel *)model hasTitle:(BOOL)hasTitle{
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.columnImg]];
    
    if (hasTitle) {
        _titleLabel.hidden = NO;
        //        _coverFlurView.hidden = YES;
        _titleLabel.text = model.name;
    }else{
        //        _coverFlurView.hidden = NO;
        _titleLabel.hidden = YES;
    }
    
    return self;
    
}
- (instancetype)setCellWithIndexPath:(NSIndexPath *)indexpath andCollectionView:(UICollectionView *)collectionView andModel:(PLProgram *)model hasTitle:(BOOL)hasTitle hasPayed:(BOOL)hasPayed{
    
    
    if (indexpath.item==0 ) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg]];
        
    }else{
        
        if (!hasPayed) {
            @weakify(self);
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg] placeholderImage:nil options:SDWebImageAvoidAutoSetImage  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                @strongify(self);
                if (image) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *images = [UIImage filterWith:image andRadius:20];
                        if (images) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                if (!_imageView.image) {
                                    
                                    self.imageView.image = images;
                                }
                            });
                        }
                    });
                }
            }];
            
//            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg] placeholderImage:nil options:SDWebImageAvoidAutoSetImage  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                @strongify(self);
//                if (image) {
//                    //todo:blur
//                    //                    self.imageView.image = image;
//                    self.imageView.image =  [UIImage filterWith:image andRadius:21];
//                }
//            }];
            
        }else{
            
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg]];
            
        }
        
        
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
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    self.effectView = toolbar;
    [self.imageView addSubview:toolbar];
    toolbar.alpha = 0.9f;
}
- (void)BlurWithImageView:(UIImageView *)imageview{
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
        
//        effectView.hidden = YES;
        //添加到要有毛玻璃特效的控件中
        [imageview addSubview:effectView];
        
        [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
        //设置模糊透明度
        effectView.alpha = 0.95f;
        
    }else{
        [self BlurWithImageViewForiOS7:nil];
        
    }
    
}

@end
