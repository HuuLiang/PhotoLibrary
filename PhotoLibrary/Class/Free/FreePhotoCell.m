//
//  FreePhotoCell.m
//  PhotoLibrary
//
//  Created by ZF on 16/2/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "FreePhotoCell.h"


static const CGFloat kImageOffset = 5;

@interface FreePhotoCell ()
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UIImageView *coverImageView;
@property (nonatomic,strong) UIImageView *freeIconImageView;
@end

@implementation FreePhotoCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_album_background"]];
        _bgImageView.hidden = YES;
        [self addSubview:_bgImageView];
        {
            [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).insets(UIEdgeInsetsMake(kImageOffset/2, kImageOffset/2, 0, 0));
            }];
        }
    }
    return self;
}

- (UIImageView *)coverImageView {
    
    if (_coverImageView) {
        return _coverImageView;
    }

    _coverImageView = [[UIImageView alloc] init];
    [_coverImageView removeFromSuperview];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    _coverImageView.layer.cornerRadius = 4;
    
    _coverImageView.layer.borderWidth = 0.5;
    _coverImageView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1].CGColor;


    [self addSubview:_coverImageView];
    {
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, kImageOffset, kImageOffset));
        }];
    }
    
    _freeIconImageView = [[UIImageView alloc] init];
    
    [_freeIconImageView removeFromSuperview];
    
    [_coverImageView addSubview:_freeIconImageView];
    {
        [_freeIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(_coverImageView);
            make.width.equalTo(_coverImageView).dividedBy(4);
            make.height.equalTo(_coverImageView).dividedBy(5);
        }];
    }
    
    return _coverImageView;
}

#pragma mark - 设置image
- (void)setImageURL:(NSURL *)imageURL{

    _imageURL = imageURL;
    _bgImageView.hidden = imageURL == nil;
    _coverImageView.layer.borderWidth = imageURL == nil ? 0 : 0.5;

    [self.coverImageView sd_setImageWithURL:imageURL];
    
}
- (void)setImageURL:(NSURL *)imageURL withFreeIcon:(BOOL)hasFreeIcon
{

    self.imageURL = imageURL;
    if (hasFreeIcon) {
        _freeIconImageView.hidden = NO;
        _freeIconImageView.image = [UIImage imageNamed:@"icon_word"];
    }else{
        _freeIconImageView.hidden = YES;
    }
}
@end
