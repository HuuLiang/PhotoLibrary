//
//  PLPhotoCell.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoCell.h"

static const CGFloat kImageOffset = 5;

@interface PLPhotoCell ()
@property (nonatomic,retain,readonly) UIImageView *imageView;
@property (nonatomic,retain,readonly) UIImageView *backgroundImageView;
@end

@implementation PLPhotoCell
@synthesize imageView = _imageView;
@synthesize backgroundImageView = _backgroundImageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_album_background"]];
        [self addSubview:_backgroundImageView];
        {
            [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).insets(UIEdgeInsetsMake(kImageOffset/2, kImageOffset/2, 0, 0));
            }];
        }
    }
    return self;
}

- (UIImageView *)imageView {
    if (_imageView) {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.layer.cornerRadius = 4;
    _imageView.layer.borderWidth = 0.5;
    _imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self addSubview:_imageView];
    {
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, kImageOffset, kImageOffset));
        }];
    }
    return _imageView;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    @weakify(self);
    [self.imageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        if (image) {
            self.imageView.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                self.imageView.alpha = 1;
            }];
        }
    }];
}
@end
