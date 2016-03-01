//
//  PLStatistics.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/14.
//  Copyright © 2015年 iqu8. All rights reserved.
//  专门用友盟做统计的模型

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
/**统计打开app相册的访问*/
+ (void)statUnlockAlbum:(PLChannelPrograms *)album {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:album.columnId.stringValue forKey:@"图集ID"];
    [MobClick event:kUnlockAlbumEventId attributes:attrs];
}
/**友盟统计app的某个照片的访问*/
+ (void)statViewAlbumPhotos:(PLProgram *)photos {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:photos.programId.stringValue forKey:@"图集ID"];
    [MobClick event:kViewPhotoEventId attributes:attrs];
}

/**统计打开视频的访问*/
+ (void)statUnlockVideo {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [MobClick event:kUnlockVideoEventId attributes:attrs];
}

/**友盟统计app的某个视频的访问*/
+ (void)statViewVideo:(PLVideo *)video {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:video.programId.stringValue forKey:@"视频ID"];
    [MobClick event:kViewVideoEventId attributes:attrs];//添加访问属性
}
/**友盟统计打开app的渠道*/
+ (void)statUnlockPhotoChannel:(PLPhotoChannel *)channel {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[self baseAttributes]];
    [attrs safelySetObject:channel.columnId.stringValue forKey:@"频道ID"];
    [attrs safelySetObject:channel.name forKey:@"频道名"];
    [MobClick event:kUnlockPhotoChannelEventId attributes:attrs];
}
/**获取渠道*/
+ (NSDictionary *)baseAttributes {
    return @{@"渠道号":[PLConfig sharedConfig].channelNo};
}
/**统计支付访问*/
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
