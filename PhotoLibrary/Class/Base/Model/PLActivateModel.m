//
//  PLActivateModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLActivateModel.h"

static NSString *const kSuccessResponse = @"SUCCESS";

@implementation PLActivateModel

+ (instancetype)sharedModel {
    static PLActivateModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[PLActivateModel alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [NSString class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}
/**激活用户，回调出userId*/
- (BOOL)activateWithCompletionHandler:(PLActivateHandler)handler {
    NSString *sdkV = [NSString stringWithFormat:@"%d.%d",
                      __IPHONE_OS_VERSION_MAX_ALLOWED / 10000,
                      (__IPHONE_OS_VERSION_MAX_ALLOWED % 10000) / 100];
    
    NSDictionary *params = @{@"cn":[PLConfiguration sharedConfig].channelNo,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"sms":@"00000000000",
                             @"cw":@(kScreenWidth),
                             @"ch":@(kScreenHeight),
                             @"cm":[PLUtil deviceName],
                             @"mf":[UIDevice currentDevice].model,
                             @"sdkV":sdkV,
                             @"cpuV":@"",
                             @"appV":@([PLUtil appVersion]).stringValue,
                             @"appVN":@""};
    
    BOOL success = [self requestURLPath:PL_ACTIVATE_URL withParams:params responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage) {
        NSString *userId;
        if (respStatus == PLURLResponseSuccess) {//请求数据成功

            NSString *resp = self.response;
            NSArray *resps = [resp componentsSeparatedByString:@";"];
            
            NSString *success = resps.firstObject;
            if ([success isEqualToString:kSuccessResponse]) {
                userId = resps.count == 2 ? resps[1] : nil;
            }
        }
        
        if (handler) {//传入的handler不为nil激活handler代码块
            handler(respStatus == PLURLResponseSuccess && userId, userId);
        }
    }];
    return success;
}

@end
