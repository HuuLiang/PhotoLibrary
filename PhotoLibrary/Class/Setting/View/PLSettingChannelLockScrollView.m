//
//  PLSettingChannelLockScrollView.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLSettingChannelLockScrollView.h"
#import "PLChannelLockView.h"
#import "PLPhotoChannel.h"
#import "PLVideo.h"

@interface PLSettingChannelLockScrollView ()
@property (nonatomic,retain) NSMutableArray<PLChannelLockView *> *photoChannelIcons;
@property (nonatomic,retain) NSMutableArray<PLChannelLockView *> *videoChannelIcons;
@end

@implementation PLSettingChannelLockScrollView

DefineLazyPropertyInitialization(NSMutableArray, photoChannelIcons)
DefineLazyPropertyInitialization(NSMutableArray, videoChannelIcons)

- (void)setPhotoChannels:(NSArray<PLPhotoChannel *> *)photoChannels {
    _photoChannels = photoChannels;
    
    [self.photoChannelIcons enumerateObjectsUsingBlock:^(PLChannelLockView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    NSMutableArray *releaseArr = self.photoChannelIcons;
    self.photoChannelIcons = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [releaseArr removeAllObjects];
    });
    
    [photoChannels enumerateObjectsUsingBlock:^(PLPhotoChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isLocked = obj.isFreeChannel ? NO : ![PLPaymentUtil isPaidForPayable:obj];
        PLChannelLockView *lockView = [[PLChannelLockView alloc] initWithTitle:obj.name
                                                                                imageURL:[NSURL URLWithString:obj.columnImg]
                                                                            isLocked:isLocked];
        @weakify(self);
        [lockView bk_whenTapped:^{
            @strongify(self);
            if (self.action) {
                self.action(PLPhotoChannelCategory, idx);
            }
        }];
        [self addSubview:lockView];
        [self.photoChannelIcons addObject:lockView];
    }];
    
    self.contentOffset = CGPointZero;
    [self setNeedsLayout];
}

- (void)setVideoChannels:(NSArray<PLVideos *> *)videoChannels {
    _videoChannels = videoChannels;
    
    [self.videoChannelIcons enumerateObjectsUsingBlock:^(PLChannelLockView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    NSMutableArray *releaseArr = self.videoChannelIcons;
    self.videoChannelIcons = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [releaseArr removeAllObjects];
    });
    
    [videoChannels enumerateObjectsUsingBlock:^(PLVideos * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isLocked = [obj payableFee].unsignedIntegerValue == 0 ? NO : ![PLPaymentUtil isPaidForPayable:obj];
        PLChannelLockView *lockView = [[PLChannelLockView alloc] initWithTitle:obj.name
                                                                      imageURL:[NSURL URLWithString:obj.columnImg]
                                                                      isLocked:isLocked];
        @weakify(self);
        [lockView bk_whenTapped:^{
            @strongify(self);
            if (self.action) {
                self.action(PLVideoChannelCategory, idx);
            }
        }];
        [self addSubview:lockView];
        [self.videoChannelIcons addObject:lockView];
    }];
    
    self.contentOffset = CGPointZero;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat leftRightPadding = 10;
    const CGSize iconSize = CGSizeMake((CGRectGetWidth(self.bounds)-leftRightPadding*2)/4, CGRectGetHeight(self.bounds));
    self.contentSize = CGSizeMake(leftRightPadding * 2 + iconSize.width * (self.photoChannelIcons.count+self.videoChannelIcons.count) , iconSize.height);
    
    CGRect orignalRect = CGRectMake(leftRightPadding, 0, iconSize.width, iconSize.height);
    
    [self.photoChannelIcons enumerateObjectsUsingBlock:^(PLChannelLockView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectOffset(orignalRect, iconSize.width * idx, 0);
    }];
    
    [self.videoChannelIcons enumerateObjectsUsingBlock:^(PLChannelLockView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectOffset(orignalRect, iconSize.width * (idx + self.photoChannelIcons.count), 0);
    }];
}
@end
