//
//  PLStatistics.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/14.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPayable.h"

@class PLPhotoChannel;
@class PLProgram;
@class PLChannelPrograms;
@class PLVideo;

@interface PLStatistics : NSObject

+ (void)start;

+ (void)statUnlockAlbum:(PLChannelPrograms *)album;
+ (void)statViewAlbumPhotos:(PLProgram *)photos;
+ (void)statUnlockVideo;
+ (void)statViewVideo:(PLVideo *)video;
+ (void)statUnlockPhotoChannel:(PLPhotoChannel *)channel;

+ (void)statPayment:(id<PLPayable>)payable;

@end
