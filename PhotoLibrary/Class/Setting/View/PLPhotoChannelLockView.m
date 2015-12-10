//
//  PLPhotoChannelLockView.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoChannelLockView.h"

@interface PLPhotoChannelLockView ()
{
    UIImageView *_thumbImageView;
    UIImageView *_lockImageView;
    UILabel *_titleLabel;
}
@property (nonatomic,retain) UIImage *originalImage;
@end

@implementation PLPhotoChannelLockView

- (instancetype)init {
    self = [super init];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12.];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
//        {
//            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.equalTo(self);
//                make.top.equalTo(_thumbImageView.mas_bottom).offset(5);
//            }];
//        }
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title imageURL:(NSURL *)imageURL isLocked:(BOOL)isLocked {
    self = [self init];
    if (self) {
        self.title = title;
        self.imageURL = imageURL;
        self.isLocked = isLocked;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat thumbImageViewWidth = CGRectGetWidth(self.bounds) * 0.8;
    const CGFloat thumbImageViewX = (CGRectGetWidth(self.bounds) - thumbImageViewWidth) / 2;
    _thumbImageView.frame = CGRectMake(thumbImageViewX, thumbImageViewX, thumbImageViewWidth, thumbImageViewWidth);
    _thumbImageView.layer.cornerRadius = thumbImageViewWidth / 2;
    
    _titleLabel.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 12.);
    _titleLabel.center = CGPointMake(_thumbImageView.center.x, CGRectGetMaxY(_thumbImageView.frame)+16);
    
    _lockImageView.bounds = CGRectMake(0, 0, 24, 24);
    _lockImageView.center = CGPointMake(CGRectGetMaxX(_thumbImageView.frame)-12, CGRectGetMaxY(_thumbImageView.frame)-12);
}

- (void)setIsLocked:(BOOL)isLocked {
    _isLocked = isLocked;
    
    if (!_lockImageView && isLocked) {
        _lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_channel_lock"]];
        [self addSubview:_lockImageView];
//        {
//            [_lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.right.bottom.equalTo(_thumbImageView);
//                make.size.mas_equalTo(CGSizeMake(24, 24));
//            }];
//        }
    }
    _lockImageView.hidden = !isLocked;
    _thumbImageView.image = isLocked ? [_thumbImageView.image grayishImage] : self.originalImage;
    
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    @weakify(self);
    [SDWebImageManager.sharedManager downloadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        @strongify(self);
        
        self.originalImage = image;
        if (self.isLocked) {
            self->_thumbImageView.image = [self->_thumbImageView.image grayishImage];
        } else {
            self->_thumbImageView.image = image;
        }
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}
@end
