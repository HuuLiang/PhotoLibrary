//
//  PLVideoCell.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/6.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLVideoCell.h"
#import "PLProgram.h"

static const CGFloat kTitleViewHeight = 30;

@interface PLVideoCell ()
{
    UIImageView *_thumbImageView;
    
    UIView *_titleView;
    UILabel *_titleLabel;
    UIImageView *_hotTagImageView;
}
@end

@implementation PLVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
        [self addSubview:_titleView];
        {
            [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.height.mas_equalTo(kTitleViewHeight);
            }];
        }
        
        UIImageView *playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_play_icon"]];
        [_titleView addSubview:playIcon];
        {
            const CGFloat iconAspect = 45. / 32.;
            [playIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(_titleView).multipliedBy(0.6);
                make.width.equalTo(playIcon.mas_height).multipliedBy(iconAspect);
                make.centerY.equalTo(_titleView);
                make.left.equalTo(_titleView).offset(8);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.];
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_titleView);
                make.left.equalTo(playIcon.mas_right).offset(8);
                make.height.equalTo(playIcon);
                make.right.equalTo(_titleView).offset(-8);
            }];
        }
    }
    return self;
}

- (void)setVideo:(PLProgram *)video {
    _video = video;
    
    _titleLabel.text = video.title;
    [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:video.coverImg]];
    
    if (!_hotTagImageView) {
        _hotTagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hot_tag"]];
        [self addSubview:_hotTagImageView];
        {
            [_hotTagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.right.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(37, 37));
            }];
        }
    }
    _hotTagImageView.hidden = !video.isHot;
}

@end
