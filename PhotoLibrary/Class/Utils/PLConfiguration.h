//
//  PLConfiguration.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLConfiguration : NSObject

@property (nonatomic,readonly) NSString *channelNo;

+ (instancetype)sharedConfig;
+ (instancetype)sharedStandbyConfig;

@end
