//
//  PLPhotoCell.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoCell.h"

@interface PLPhotoCell ()
@property (nonatomic,retain,readonly) UIImageView *imageView;
@end

@implementation PLPhotoCell
@synthesize imageView = _imageView;

- (UIImageView *)imageView {
    if (_imageView) {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    {
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
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
