//
//  PLSystemConfigModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLSystemConfigModel.h"

@implementation PLSystemConfigResponse

- (Class)confisElementClass {
    return [PLSystemConfig class];
}

@end

@implementation PLSystemConfigModel

+ (instancetype)sharedModel {
    static PLSystemConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[PLSystemConfigModel alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [PLSystemConfigResponse class];
}
/**获取系统配置参数*/
- (BOOL)fetchSystemConfigWithCompletionHandler:(PLFetchSystemConfigCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:PL_SYSTEM_CONFIG_URL
                             withParams:nil
                        responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (respStatus == PLURLResponseSuccess) {
            PLSystemConfigResponse *resp = self.response;
            
            [resp.confis enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PLSystemConfig *config = obj;
                
                if ([config.name isEqualToString:PL_SYSTEM_CONFIG_PAY_TYPE]) {
                    [PLSystemConfigModel sharedModel].isApplePay = config.value;
                } else if ([config.name isEqualToString:PL_SYSTEM_CONFIG_GALLERY_PAY_AMOUNT]) {
                    [PLSystemConfigModel sharedModel].photoPrice = [config.value integerValue];
                } else if ([config.name isEqualToString:PL_SYSTEM_CONFIG_VIDEO_PAY_AMOUNT]) {
                    [PLSystemConfigModel sharedModel].videoPrice = [config.value integerValue];
                } else if ([config.name isEqualToString:PL_SYSTEM_CONFIG_CHANNEL_TOP_IMG]) {
                    [PLSystemConfigModel sharedModel].ChannelBannerImgUrl = config.value;
                } else if ([config.name isEqualToString:PL_SYSTEM_CONFIG_SPREAD_TOP_IMG]) {
                    [PLSystemConfigModel sharedModel].channelPopImgUrl = config.value;
                } else if ([config.name isEqualToString:PL_SYSTEM_CONFIG_ISAPPLE_PAY]){
                    [PLSystemConfigModel sharedModel].isAppleStore = config.value;
                }else if ([config.name isEqualToString:PL_SYSTEM_CONFIG_PAYMENT_IMG]){
                    [PLSystemConfigModel sharedModel].payImage = config.value;
                }
            }];
        }
        
        if (handler) {
            handler(respStatus==PLURLResponseSuccess);
        }
    }];
    return success;
}

@end
