//
//  PLPopupMenuButton.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPopupMenuButton.h"

static const CGFloat kPadding = 5;

@interface PLPopupMenuButton ()
{
    UIImageView *_roundRectBgImageView;
    UIImageView *_thumbImageView;
    UILabel *_thumbTitleLabel;
    UIImageView *_markImageView;
    UIImageView *_lockImageView;
}
@property (nonatomic,retain) UIImage *originalThumbImage;
@end

@implementation PLPopupMenuButton

+ (instancetype)buttonWithTitle:(NSString *)title imageURL:(NSURL *)imageURL {
    PLPopupMenuButton *button = [[self alloc] init];
    return button;
}

- (instancetype)initWithTitle:(NSString *)title imageURL:(NSURL *)imageURL {
    self = [super init];
    if (self) {
        _title = title;
        _imageURL = imageURL;
        
        self.layer.cornerRadius = 5;
        [self setBackgroundImage:[UIImage imageNamed:@"popup_menu_normal_background"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"popup_menu_selected_background"] forState:UIControlStateSelected];
        
        _roundRectBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_menu_thumb_normal_background"]];
        [self addSubview:_roundRectBgImageView];
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        
        _thumbTitleLabel = [[UILabel alloc] init];
        _thumbTitleLabel.font = [UIFont boldSystemFontOfSize:15.];
        _thumbTitleLabel.textAlignment = NSTextAlignmentCenter;
        _thumbTitleLabel.adjustsFontSizeToFitWidth = YES;
        _thumbTitleLabel.text = title;
        [self addSubview:_thumbTitleLabel];
        
        _markImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_menu_marked"]];
        _markImageView.hidden = YES;
        [self addSubview:_markImageView];
        
        _lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_menu_lock"]];
        _lockImageView.hidden = YES;
        [self addSubview:_lockImageView];
        
        [self setImageURL:imageURL];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _thumbTitleLabel.text = title;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    @weakify(self);
    [_thumbImageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        self.originalThumbImage = image;
        
        if (image && self.isLocked) {
            _thumbImageView.image = [image grayishImage];
        }
    }];
}

- (void)setIsLocked:(BOOL)isLocked {
    _isLocked = isLocked;
    
    if (isLocked) {
        _roundRectBgImageView.image = [UIImage imageNamed:@"popup_menu_thumb_normal_background"];
    } else {
        _roundRectBgImageView.image = [UIImage imageNamed:@"popup_menu_thumb_selected_background"];
    }
    _markImageView.hidden = isLocked;
    _lockImageView.hidden = !isLocked;
    
    if (self.originalThumbImage) {
        _thumbImageView.image = isLocked ? [self.originalThumbImage grayishImage] : self.originalThumbImage;
    }
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [self imageRectForContentRect:contentRect];
    CGFloat width = CGRectGetWidth(contentRect)*0.7-CGRectGetWidth(imageRect)-kPadding*2;
    CGRect titleRect = CGRectMake(CGRectGetMaxX(imageRect)+kPadding, imageRect.origin.y, width, CGRectGetHeight(imageRect));
    return titleRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageSize = MIN(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds)) - kPadding * 2;
    CGRect imageRect = CGRectMake(self.bounds.origin.x + kPadding, self.bounds.origin.y + kPadding, imageSize, imageSize);
    
    _roundRectBgImageView.frame = imageRect;
    _thumbImageView.frame = CGRectInset(imageRect, 2, 2);
    _thumbImageView.layer.cornerRadius = CGRectGetWidth(_thumbImageView.frame) / 2;
    _markImageView.frame = CGRectMake(imageRect.origin.x + imageSize/2 -5,
                                      imageRect.origin.y + imageSize/2 -5,
                                      imageSize*0.8, imageSize*0.8);
    _lockImageView.center = _thumbImageView.center;
    _lockImageView.bounds = CGRectMake(0, 0, CGRectGetWidth(_thumbImageView.frame)/2, CGRectGetHeight(_thumbImageView.frame)/2);
    
    CGFloat width = CGRectGetWidth(self.bounds)*0.7-CGRectGetWidth(imageRect)-kPadding*2;
    CGRect titleRect = CGRectMake(CGRectGetMaxX(imageRect)+kPadding, imageRect.origin.y, width, CGRectGetHeight(imageRect));
    _thumbTitleLabel.frame = titleRect;
    
}
@end
