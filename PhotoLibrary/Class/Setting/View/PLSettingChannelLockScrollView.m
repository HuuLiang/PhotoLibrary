//
//  PLSettingChannelLockScrollView.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLSettingChannelLockScrollView.h"
#import "PLPhotoChannelLockView.h"
#import "PLPhotoChannel.h"

@interface PLSettingChannelLockScrollView ()
@property (nonatomic,retain) NSMutableArray<PLPhotoChannelLockView *> *channelIcons;
@end

@implementation PLSettingChannelLockScrollView

DefineLazyPropertyInitialization(NSMutableArray, channelIcons)

- (void)setChannels:(NSArray<PLPhotoChannel *> *)channels {
    _channels = channels;
    
    [self.channelIcons enumerateObjectsUsingBlock:^(PLPhotoChannelLockView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    NSMutableArray *releaseArr = self.channelIcons;
    self.channelIcons = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [releaseArr removeAllObjects];
    });
    
    [channels enumerateObjectsUsingBlock:^(PLPhotoChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isLocked = obj.isFreeChannel ? NO : ![PLPaymentUtil isPaidForPayable:obj];
        PLPhotoChannelLockView *lockView = [[PLPhotoChannelLockView alloc] initWithTitle:obj.name
                                                                                imageURL:[NSURL URLWithString:obj.columnImg]
                                                                                isLocked:isLocked];
        [self addSubview:lockView];
        [self.channelIcons addObject:lockView];
    }];
    
    self.contentOffset = CGPointZero;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat leftRightPadding = 10;
    const CGSize iconSize = CGSizeMake((CGRectGetWidth(self.bounds)-leftRightPadding*2)/4, CGRectGetHeight(self.bounds));
    self.contentSize = CGSizeMake(leftRightPadding * 2 + iconSize.width * self.channelIcons.count , iconSize.height);
    
    [self.channelIcons enumerateObjectsUsingBlock:^(PLPhotoChannelLockView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(leftRightPadding + iconSize.width * idx,
                               0,
                               iconSize.width,
                               iconSize.height);
    }];
}
@end
