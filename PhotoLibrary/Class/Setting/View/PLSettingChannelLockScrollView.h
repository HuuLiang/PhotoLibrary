//
//  PLSettingChannelLockScrollView.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPhotoChannel;

typedef void (^PLLockScrollViewAction)(NSUInteger index);

@interface PLSettingChannelLockScrollView : UIScrollView

@property (nonatomic,retain) NSArray<PLPhotoChannel *> *channels;
@property (nonatomic,copy) PLLockScrollViewAction action;

@end
