//
//  PLPhotoChannel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPayable.h"

@interface PLPhotoChannel : NSObject <PLPayable>

@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSString *columnDesc;
@property (nonatomic) NSNumber *type;
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *payAmount;

- (BOOL)isSameChannel:(PLPhotoChannel *)channel;
- (BOOL)isFreeChannel;

+ (instancetype)persistentPhotoChannel;
- (void)writeToPersistence;

@end
