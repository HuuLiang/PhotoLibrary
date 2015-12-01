//
//  PLErrorHandler.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLErrorHandler : NSObject

+ (instancetype)sharedHandler;
- (void)initialize;

@end

extern NSString *const kNetworkErrorNotification;
extern NSString *const kNetworkErrorCodeKey;
extern NSString *const kNetworkErrorMessageKey;