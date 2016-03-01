//
//  PLSettingChannelLockScrollView.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPhotoChannel;
@class PLVideos;

typedef void (^PLLockScrollViewAction)(PLChannelCategory channelCategory, NSUInteger index);

@interface PLSettingChannelLockScrollView : UIScrollView

@property (nonatomic,retain) NSArray<PLPhotoChannel *> *photoChannels;
@property (nonatomic,retain) NSArray<PLVideos *> *videoChannels;
@property (nonatomic,copy) PLLockScrollViewAction action;

@end
