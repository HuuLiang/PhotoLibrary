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
    BOOL success = [self requestURLPath:[PLConfig sharedConfig].systemConfigURLPath
                         standbyURLPath:[PLConfig sharedStandbyConfig].systemConfigURLPath
                             withParams:nil
                        responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (respStatus == PLURLResponseSuccess) {
            PLSystemConfigResponse *resp = self.response;
            
            [resp.confis enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PLSystemConfig *config = obj;
                
                if ([config.name isEqualToString:[PLConfig sharedConfig].systemConfigPayAmount]) {
                    self.payAmount = config.value.doubleValue / 100.;
                } else if ([config.name isEqualToString:[PLConfig sharedConfig].systemConfigSpreadTopImage]) {
                    self.spreadTopImage = config.value;
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
