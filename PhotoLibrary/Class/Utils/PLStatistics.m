//
//  PLStatistics.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/14.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLStatistics.h"
#import "MobClick.h"
#import "PLPhotoChannel.h"
#import "PLChannelProgram.h"
#import "PLVideo.h"

static NSString *const kUnlockAlbumEventId = @"PL_UNLOCK_ALBUM";
static NSString *const kViewPhotoEventId = @"PL_PHOTO_VIEW";
static NSString *const kUnlockVideoEventId = @"PL_UNLOCK_VIDEO";
static NSString *const kViewVideoEventId = @"PL_VIDEO_VIEW";
static NSString *const kUnlockPhotoChannelEventId = @"PL_UNLOCK_CHANNEL";

@implementation PLStatistics

+ (void)start {
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    NSString *bundleVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if (bundleVersion) {
        [MobClick setAppVersion:bundleVersion];
    }
    [MobClick startWithAppkey:[PLConfig sharedConfig].umengAppId reportPolicy:BATCH channelId:[PLConfig sharedConfig].channelNo];
}

+ (void)statUnlockAlbum:(PLChannelPrograms *)album {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:album.columnId.stringValue forKey:@"图集ID"];
    [MobClick event:kUnlockAlbumEventId attributes:attrs];
}

+ (void)statViewAlbumPhotos:(PLProgram *)photos {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:photos.programId.stringValue forKey:@"图集ID"];
    [MobClick event:kViewPhotoEventId attributes:attrs];
}

+ (void)statUnlockVideo {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [MobClick event:kUnlockVideoEventId attributes:attrs];
}

+ (void)statViewVideo:(PLVideo *)video {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:video.programId.stringValue forKey:@"视频ID"];
    [MobClick event:kViewVideoEventId attributes:attrs];
}

+ (void)statUnlockPhotoChannel:(PLPhotoChannel *)channel {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:channel.columnId.stringValue forKey:@"频道ID"];
    [attrs safelySetObject:channel.name forKey:@"频道名"];
    [MobClick event:kUnlockPhotoChannelEventId attributes:attrs];
}

+ (NSDictionary *)baseAttributes {
    return @{@"渠道号":[PLConfig sharedConfig].channelNo};
}

+ (void)statPayment:(id<PLPayable>)payable {
    if ([payable payableUsage] == PLPaymentForPhotoChannel) {
        [self statUnlockPhotoChannel:(PLPhotoChannel *)payable];
    } else if ([payable payableUsage] == PLPaymentForPhotoAlbum) {
        [self statUnlockAlbum:(PLChannelPrograms *)payable];
    } else if ([payable payableUsage] == PLPaymentForVideo) {
        [self statUnlockVideo];
    }
}
@end
