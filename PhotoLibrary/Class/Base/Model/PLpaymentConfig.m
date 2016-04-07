//
//  PLPaymentConfig.m
//  PhotoLibrary
//
//  Created by ZF on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLPaymentConfig.h"

@implementation PLWeChatPaymentConfig


+ (instancetype)defaultConfig {
    PLWeChatPaymentConfig *config = [[self alloc] init];
    config.appId = @"wx4af04eb5b3dbfb56";
    config.mchId = @"1281148901";
    config.signKey = @"hangzhouquba20151112qwertyuiopas";
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWx.json";
    return config;
}
@end


@implementation PLAlipayConfig

@end

@implementation PLIAppPayConfig

+ (instancetype)defaultConfig {
    PLIAppPayConfig *config = [[self alloc] init];
    config.appid = @"3004666841";
    config.privateKey = @"MIICXAIBAAKBgQCDYjujgETHtro383gco6rXHcZfuyZ8dimK/zub0fMHhESI9JvH/3SLzhhbdIv3mndnGMSCGXFP7rlMW9pf+76CiWuYPHGs9nVzRw5jX6aemiq54WLJCC6syyDKpmzNHWKF1bwjqMbgUVvy2hYb4BJN8ahaE0KjJJ6AOmUi13fgewIDAQABAoGAOV6GnjFfVzmx/MaCdzb8XWxx99FXz9ck8r3agILftTOLXaY5883XTUjUF/M/PwIjC1CkVg7YDMg3/2DIbUsW93XWHcZQP8VkTxmmRxsuq9olk2Z/LrIkoMcDU028gb4BIp/Ea1ujLXpqUDJaIfoFVbhcDqZhr6X3aXhdRRe9isECQQDOSfdacG6lr4EwhZBiYwk/IjcEDX5KEm1RztiUcAyERUyFy83Y7kvdL3kXDBVkV1TnA8d/LNaY+wQ/g4jMKOPbAkEAowtW04M3FzBXf0kdZ5zjau0NRbTt1pnR5FP5Mw+2h5KaqRwGaLlJZNDWyqGScBto/b6/aRkQXbzORhcg/9fn4QJBAMdWwFg7ZyBh/MPHfSMlsky4olMfOtcXAV5ZM/4UXHQAhxaPP0YN129QLYHw4kcJAPkPNNsWl/RSM+OwFiO6q5sCQCLP4/0LUjLwTm5OBSo/VEtbS+8rP3EHrMoMp/OgEkAGLGGZK0Em9qXA9WuUbfjj0VoEZUgiYt0w1/YdMB2QUuECQHO/Xp6+RX8lcWugXd+NWsJQqgpPpO+nDvJJKg5f/9+P5xqfA4Z0Kz0JjmQYRv2NQJX9GOodXG3EsxVKWsJ48gU=";
    config.publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDGUdxLNXQ4jvqAZm3oQE1WX014JC1yT2nsL29CSgtma6exJdvLlsrk/QTCKy8SIAEVQ3bawYWRrr6JVZVwx9i98TlmAmZyj5tdvWZbYcfi5xWu2tM0jM/7kH5itgD+LoV7VYpWrdcMbF1No+fK7aO66KMeii/cFxzx2RBxnUtKpQIDAQAB";
    config.waresid = @(1);
    config.supportPayTypes = @(1);
    return config;
}

@end

@interface PLPaymentConfigRespCode : NSObject
@property (nonatomic) NSNumber *value;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *message;
@end

@implementation PLPaymentConfigRespCode

@end

static PLPaymentConfig *_shardConfig;

@interface PLPaymentConfig ()
@property (nonatomic) PLPaymentConfigRespCode *code;
@end

@implementation PLPaymentConfig

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shardConfig = [[self alloc] init];
        [_shardConfig loadDefaultConfig];
    });
    return _shardConfig;
}

- (NSNumber *)success {
    return self.code.value.unsignedIntegerValue == 100 ? @(1) : (0);
}

- (NSString *)resultCode {
    return self.code.value.stringValue;
}

- (Class)codeClass {
    return [PLPaymentConfigRespCode class];
}

- (Class)weixinInfoClass {
    return [PLWeChatPaymentConfig class];
}

- (Class)alipayInfoClass {
    return [PLAlipayConfig class];
}

- (Class)iappPayInfoClass {
    return [PLIAppPayConfig class];
}

- (void)loadDefaultConfig {
    self.weixinInfo = [PLWeChatPaymentConfig defaultConfig];
}

- (void)setAsCurrentConfig {
    PLPaymentConfig *currentConfig = [[self class] sharedConfig];
    currentConfig.weixinInfo = self.weixinInfo;
    currentConfig.iappPayInfo = self.iappPayInfo;
    currentConfig.alipayInfo = self.alipayInfo;
}


@end
