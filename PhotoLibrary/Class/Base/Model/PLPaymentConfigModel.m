//
//  PLPaymentConfigModel.m
//  PhotoLibrary
//
//  Created by ZF on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLPaymentConfigModel.h"
#import "NSDictionary+PLSign.h"
#import "PLPaymentConfig.h"
static NSString *const kSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";



@implementation PLPaymentConfigModel


+ (Class)responseClass {
    return [PLPaymentConfig class];
}

+ (instancetype)sharedModel {
    static PLPaymentConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (PLURLRequestMethod)requestMethod {
    return PLURLPostRequest;
}

+ (NSString *)signKey {
    return kSignKey;
}
/**
 *  参数加密
 *
 *  @param params 加密前参数
 *
 *  @return 加密后参数
 */
- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":PL_REST_APP_ID,
                                   @"key":kSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":PL_CHANNEL_NO,
                                   @"pV":PL_PAY_REST_PV };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":PL_REST_APP_ID};
}

/**
 *  从后台获取支付配置信息
 *
 *  @param handler 回调
 *
 *  @return 获取成功/失败
 */
- (BOOL)fetchConfigWithCompletionHandler:(PLPaymentConfigCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:PL_PAYMENT_CONFIG_URL
                     standbyURLPath:[NSString stringWithFormat:PL_STANDBY_PAYMENT_CONFIG_URL, PL_REST_APP_ID]
                         withParams:@{@"appId":PL_REST_APP_ID, @"channelNo":PL_CHANNEL_NO, @"pV":PL_PAY_REST_PV}
                    responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
                {
                    @strongify(self);
                    if (!self) {
                        return ;
                    }
                    
                    PLPaymentConfig *config;
                    if (respStatus == PLURLResponseSuccess) {
                        self->_loaded = YES;
                        
                        config = self.response;
//                        if (!config.iappPayInfo) {
//                            config.iappPayInfo = [PLIAppPayConfig defaultConfig];
//                        }
                        [config setAsCurrentConfig];
                        
                        DLog(@"Payment config loaded!");
                    }
                    
                    if (handler) {
                        handler(respStatus == PLURLResponseSuccess, config);
                    }
                }];
    return ret;
}

@end
