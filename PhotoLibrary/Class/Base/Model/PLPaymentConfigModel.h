//
//  PLPaymentConfigModel.h
//  PhotoLibrary
//
//  Created by ZF on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLPaymentConfig.h"
typedef void (^PLPaymentConfigCompletionHandler)(BOOL success,PLPaymentConfig*config);

@interface PLPaymentConfigModel : PLEncryptedURLRequest
@property (nonatomic,readonly) BOOL loaded;

+ (instancetype)sharedModel;
/**
 *  从后台获取支付配置信息
 *
 *  @param handler 回调
 *
 *  @return 获取成功/失败
 */
- (BOOL)fetchConfigWithCompletionHandler:(PLPaymentConfigCompletionHandler)handler;
@end
