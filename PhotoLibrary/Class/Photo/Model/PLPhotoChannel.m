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

@end
