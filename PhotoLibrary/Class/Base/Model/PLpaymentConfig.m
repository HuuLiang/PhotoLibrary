//
//  PLPaymentConfig.m
//  PhotoLibrary
//
//  Created by ZF on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLPaymentConfig.h"
#import "NSMutableDictionary+Safety.h"

static NSString *const kSystemConfigKeyName = @"photolibrary_systemconfig_keyname";

@implementation PLWeChatPaymentConfig


+ (instancetype)defaultConfig {
    PLWeChatPaymentConfig *config = [[self alloc] init];
    config.appId = @"wx4e086cf2c5bebcd5";//@"wx4af04eb5b3dbfb56";//
    config.mchId = @"1323603901";//@"1281148901";//
    config.signKey = @"hangzhouquya20160713qwertyuiopas";//@"hangzhouquba20151112qwertyuiopas";
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWx.json";
    return config;
}
- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (dic.count == 0) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        self.appId = dic[@"appId"];
        self.mchId = dic[@"mchId"];
        self.signKey = dic[@"signKey"];
        self.notifyUrl = dic[@"notifyUrl"];
    }
    return self;
}
- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safely_setObject:self.appId forKey:@"appId"];
    [dic safely_setObject:self.mchId forKey:@"mchId"];
    [dic safely_setObject:self.signKey forKey:@"signKey"];
    [dic safely_setObject:self.notifyUrl forKey:@"notifyUrl"];
    return dic.count > 0 ? dic : nil;
}

- (BOOL)isValid {
    return self.appId.length > 0 && self.mchId.length > 0 && self.signKey.length > 0 && self.notifyUrl.length > 0;
}


@end


@implementation PLAlipayConfig

+ (instancetype)defaultConfig {
    PLAlipayConfig *defaultConfig = [[self alloc] init];
    defaultConfig.partner = @"2088121511256613";
    defaultConfig.seller = @"wuyp@iqu8.cn";
    defaultConfig.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyByAlipay.json";
    defaultConfig.productInfo = @"相约交友";
    defaultConfig.privateKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAMXv/hpnzbA3rO/P5KJKatb3NugTw965VYzcdEFyv38iIpMA3io7/kEcuMRGMDQ0VQJgNaF8/sHDu/j/+NPSDBzeOKtsqVsZoY5jKK1K43LujAYz2v8lvNLkFcaFoUhfMXHhxNnoHNtGXIadhHFK+v2a1l3YCZiP5XJ3rQo1FbrBAgMBAAECgYA4XFbJZAdQhvnqKxMaFwCHB0uOF5qtP66Zdmhv/mGCrNCVdSjNc9m45pnB4Y52PvR5wbVjrzjHKZnLk+9hOS0TRkbOmiuCfxB2doB3YMeGlgo+rPSUL0Ey5WKF8+IJvImQfgf8kgJlU/7RPeAtfY+pmxY9PvbULHKGS5q8KHXLFQJBAPtJ0S1idGtnRXX8f2+I7aqmxnH3QwVtU2DhN++l6n+XIEWmNgvVJoLY/bdtK84lKZl9nJw3hSVZ6C6qN1F7up8CQQDJphduiRVezGSR0ofcOBwT/jTxynovFH4zhdWLu/4f3p9fHvKFqYqdgv8Z5lUr4W6Bga+k0hLuqGvJjXAyI+6fAkAvHqNjsD+GWEIVIri+sF1oj4dMnYHqxZpJ41F61ZDIRg1eIhGmXFyxUoEY4RbCvAM17fDs9hg4bch036Qp2lqfAkBj9VByO8P7LSjBXHJ6iNnqUz4dibhNtEPm+HXmAbe0RqAMAARKm8OZ1wDr7tDTorkru4S9GGHIKnbb/5/ZSxSTAkB+cIT779yzXIVZYNj8Q2C+FMiHdUrw9OVikW6nKRcIlJJMBQfPzvjfR5ux0NVi1CM76hl5C4f4GSKFgM7AYXwX";
    return defaultConfig;
}

- (BOOL)isValid {
    return self.partner.length > 0 && self.privateKey.length > 0 && self.seller.length > 0 && self.notifyUrl.length > 0;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (dic.count == 0) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        self.partner = dic[@"partner"];
        self.privateKey = dic[@"privateKey"];
        self.productInfo = dic[@"productInfo"];
        self.seller = dic[@"seller"];
        self.notifyUrl = dic[@"notifyUrl"];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safely_setObject:self.partner forKey:@"partner"];
    [dic safely_setObject:self.privateKey forKey:@"privateKey"];
    [dic safely_setObject:self.productInfo forKey:@"productInfo"];
    [dic safely_setObject:self.seller forKey:@"seller"];
    [dic safely_setObject:self.notifyUrl forKey:@"notifyUrl"];
    return dic.count > 0 ? dic : nil;
}



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
        //        _shardConfig = [[self alloc] init];
        //        [_shardConfig loadDefaultConfig];
        _shardConfig = [self configFromPersistence];
    });
    if (!_shardConfig.alipayInfo.isValid ) {
        _shardConfig.alipayInfo = [[self defaultConfig] alipayInfo];
    }
    if (!_shardConfig.weixinInfo.isValid) {
        _shardConfig.weixinInfo = [[self defaultConfig] weixinInfo];
    }
    
    if (_shardConfig.imgUrl.length == 0) {
        _shardConfig.imgUrl = [[self defaultConfig] imgUrl];
    }
    
    if (_shardConfig.firstPayPages == nil) {
        _shardConfig.firstPayPages = [[self defaultConfig] firstPayPages];
    }
    
    if (_shardConfig.vipPointInfo.length == 0) {
        _shardConfig.vipPointInfo = [[self defaultConfig] vipPointInfo];
    }

    return _shardConfig;
}

+ (instancetype)configFromPersistence {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kSystemConfigKeyName];
    return [[self alloc] initFromDictionary:dic];
}

- (instancetype)initFromDictionary:(NSDictionary *)dic {
    self = [self init];
    if (self) {
        self.imgUrl = dic[@"imgUrl"];
        self.firstPayPages = dic[@"firstPayPages"];
        self.vipPointInfo = dic[@"vipPointInfo"];
        self.ballPayWindowurl = dic[@"ballPayWindowurl"];
        self.payImgUrl = dic[@"payImgUrl"];
        self.userNames = dic[@"userNames"];
        
        self.alipayInfo = [[PLAlipayConfig alloc] initWithDictionary:dic[@"alipayInfo"]];
        self.weixinInfo = [[PLWeChatPaymentConfig alloc] initWithDictionary:dic[@"weixinInfo"]];
    }
    return self;
}

- (void)persist {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kSystemConfigKeyName];
    NSMutableDictionary *persistDic = [dic mutableCopy];
    if (!persistDic) {
        persistDic = [NSMutableDictionary dictionary];
    }
    
    [persistDic safely_setObject:self.imgUrl forKey:@"imgUrl"];
    [persistDic safely_setObject:self.firstPayPages forKey:@"firstPayPages"];
    [persistDic safely_setObject:self.vipPointInfo forKey:@"vipPointInfo"];
    [persistDic safely_setObject:self.ballPayWindowurl forKey:@"ballPayWindowurl"];
    [persistDic safely_setObject:self.payImgUrl forKey:@"payImgUrl"];
    [persistDic safely_setObject:self.userNames forKey:@"userNames"];
    [persistDic safely_setObject:self.alipayInfo.dictionaryRepresentation forKey:@"alipayInfo"];
    [persistDic safely_setObject:self.weixinInfo.dictionaryRepresentation forKey:@"weixinInfo"];
    [[NSUserDefaults standardUserDefaults] setObject:persistDic forKey:kSystemConfigKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_shardConfig != self) {
        _shardConfig = self;
    }
}
- (Class)userNamesElementClass {
    return [PLPaymentConfig class];
}
+ (instancetype)defaultConfig {
    static PLPaymentConfig *_defaultConfig;
    static dispatch_once_t defaultToken;
    dispatch_once(&defaultToken, ^{
        _defaultConfig = [[self alloc] init];
        _defaultConfig.alipayInfo = [PLAlipayConfig defaultConfig];
        _defaultConfig.weixinInfo = [PLWeChatPaymentConfig defaultConfig];
        _defaultConfig.imgUrl = PL_DEFAULT_PHOTOSERVER_URL;
        _defaultConfig.firstPayPages = @2;
        _defaultConfig.vipPointInfo = @"4800:1|9800:3";
    });
    return _defaultConfig;
}

- (Class)alipayInfoClass {
    return [PLAlipayConfig class];
}

- (Class)weixinInfoClass {
    return [PLWeChatPaymentConfig class];
}

- (NSNumber *)success {
    return self.code.value.unsignedIntegerValue == 100 ? @(1) : (0);
}
//
- (NSString *)resultCode {
    return self.code.value.stringValue;
}
//
- (Class)codeClass {
    return [PLPaymentConfigRespCode class];
}

- (void)loadDefaultConfig {
    self.weixinInfo = [PLWeChatPaymentConfig defaultConfig];
}

- (void)setAsCurrentConfig {
    PLPaymentConfig *currentConfig = [[self class] sharedConfig];
    currentConfig.weixinInfo = self.weixinInfo;
    currentConfig.alipayInfo = self.alipayInfo;
}


@end
