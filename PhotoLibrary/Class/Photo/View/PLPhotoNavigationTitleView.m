//
//  PLPhotoNavigationTitleView.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoNavigationTitleView.h"

static const CGFloat kThumbImageViewSize = 40;

@interface PLPhotoNavigationTitleView ()
{
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_thumbImageView;
}
@end

@implementation PLPhotoNavigationTitleView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18.];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [UIFont systemFontOfSize:12.];
    _subtitleLabel.textColor = [UIColor whiteColor];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_subtitleLabel];
    {
        [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
            make.top.equalTo(_titleLabel.mas_bottom).offset(2);
        }];
    }
    
    _thumbImageView = [[UIImageView alloc] init];
    _thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _thumbImageView.layer.borderWidth = 1;
    _thumbImageView.layer.cornerRadius = kThumbImageViewSize / 2.;
    _thumbImageView.layer.masksToBounds = YES;
    _thumbImageView.hidden = YES;
    [self addSubview:_thumbImageView];
}

- (void)titleLabelRemakeConstraints {
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).offset(_thumbImageView.image?-kThumbImageViewSize/2:0);
    }];
}

- (void)imageViewRemakeConstraints {
    [_thumbImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        
        if (_titleLabel.text.length > 0 && !_titleLabel.hidden) {
            make.left.equalTo(_titleLabel.mas_right).offset(10);
        } else {
            make.centerX.equalTo(self);
        }
        
        make.size.mas_equalTo(CGSizeMake(kThumbImageViewSize, kThumbImageViewSize));
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
    [self titleLabelRemakeConstraints];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    @weakify(self);
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        self->_thumbImageView.hidden = image == nil;
        
        if (image) {
            [self titleLabelRemakeConstraints];
            [self imageViewRemakeConstraints];
        }
    }];
}
@end
