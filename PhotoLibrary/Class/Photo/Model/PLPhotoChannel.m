//
//  PLPhotoChannel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoChannel.h"

@implementation PLPhotoChannel

- (NSNumber *)payableFee {
#ifdef DEBUG
    return @1;
#else
    return self.payAmount;
#endif
}

- (PLPaymentUsage)payableUsage {
    return PLPaymentForPhotoChannel;
}

- (NSNumber *)contentId {
    return self.columnId;
}

- (NSNumber *)contentType {
    return self.type;
}

- (NSNumber *)payPointType {
    return nil;
}

- (BOOL)isSameChannel:(PLPhotoChannel *)channel {
    return self.columnId && [self.columnId isEqualToNumber:channel.columnId];
}

- (BOOL)isFreeChannel {
    return self.payAmount.unsignedIntegerValue == 0;
}

+ (instancetype)persistentPhotoChannel {
    NSDictionary *channelDic = [[NSUserDefaults standardUserDefaults] objectForKey:kPhotoChannelIdKeyName];
    return [self photoChannelFromDictionary:channelDic];
}

+ (instancetype)photoChannelFromDictionary:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    
    PLPhotoChannel *channel = [[PLPhotoChannel alloc] init];
    channel.columnId        = dic[@"columnId"];
    channel.name            = dic[@"name"];
    channel.columnImg       = dic[@"columnImg"];
    channel.type            = dic[@"type"];
    channel.showNumber      = dic[@"showNumber"];
    channel.columnDesc      = dic[@"columnDesc"];
    channel.payAmount       = dic[@"payAmount"];
    return channel;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safelySetObject:self.columnId forKey:@"columnId"];
    [dic safelySetObject:self.name forKey:@"name"];
    [dic safelySetObject:self.columnImg forKey:@"columnImg"];
    [dic safelySetObject:self.type forKey:@"type"];
    [dic safelySetObject:self.showNumber forKey:@"showNumber"];
    [dic safelySetObject:self.columnDesc forKey:@"columnDesc"];
    [dic safelySetObject:self.payAmount forKey:@"payAmount"];
    return dic;
}

- (void)writeToPersistence {
    [[NSUserDefaults standardUserDefaults] setObject:self.dictionary forKey:kPhotoChannelIdKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
