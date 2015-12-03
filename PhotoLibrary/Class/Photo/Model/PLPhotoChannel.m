//
//  PLPhotoChannel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoChannel.h"

@implementation PLPhotoChannel

- (BOOL)isSameChannel:(PLPhotoChannel *)channel {
    return self.columnId && [self.columnId isEqualToNumber:channel.columnId];
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
    channel.items           = dic[@"items"];
    channel.page            = dic[@"page"];
    channel.pageSize        = dic[@"pageSize"];
    return channel;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safelySetObject:self.columnId forKey:@"columnId"];
    [dic safelySetObject:self.name forKey:@"name"];
    [dic safelySetObject:self.columnImg forKey:@"columnImg"];
    [dic safelySetObject:self.type forKey:@"type"];
    [dic safelySetObject:self.showNumber forKey:@"showNumber"];
    [dic safelySetObject:self.items forKey:@"items"];
    [dic safelySetObject:self.page forKey:@"page"];
    [dic safelySetObject:self.pageSize forKey:@"pageSize"];
    return dic;
}

- (void)writeToPersistence {
    [[NSUserDefaults standardUserDefaults] setObject:self.dictionary forKey:kPhotoChannelIdKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
