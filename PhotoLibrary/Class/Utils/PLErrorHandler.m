//
//  PLErrorHandler.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLErrorHandler.h"
#import "PLURLRequest.h"

NSString *const kNetworkErrorNotification = @"PLNetworkErrorNotification";
NSString *const kNetworkErrorCodeKey = @"PLNetworkErrorCodeKey";
NSString *const kNetworkErrorMessageKey = @"PLNetworkErrorMessageKey";

@implementation PLErrorHandler

+ (instancetype)sharedHandler {
    static PLErrorHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[PLErrorHandler alloc] init];
    });
    return _handler;
}

- (void)initialize {
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkError:) name:kNetworkErrorNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**接到通知后响应时间*/
- (void)onNetworkError:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    PLURLResponseStatus resp = (PLURLResponseStatus)(((NSNumber *)userInfo[kNetworkErrorCodeKey]).unsignedIntegerValue);
    
    if (resp == PLURLResponseFailedByInterface) {
        [[PLHudManager manager] showHudWithText:@"获取网络数据失败"];
    } else if (resp == PLURLResponseFailedByNetwork) {
        [[PLHudManager manager] showHudWithText:@"网络错误，请检查网络连接！"];
    }
    
}
@end
