//
//  PLConfiguration.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLConfiguration.h"

static NSString *const kDefaultConfigName = @"config";
static NSString *const kDefaultStandbyConfigName = @"config_standby";

@implementation PLConfiguration

+ (instancetype)sharedConfig {
    static PLConfiguration *_config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [self configWithName:kDefaultConfigName];
    });
    return _config;
}

+ (instancetype)sharedStandbyConfig {
    static PLConfiguration *_standbyConfig;
    static dispatch_once_t standbyOnceToken;
    dispatch_once(&standbyOnceToken, ^{
        _standbyConfig = [self configWithName:kDefaultStandbyConfigName];
    });
    return _standbyConfig;
}

+ (instancetype)configWithName:(NSString *)configName {
    NSString *configPath = [[NSBundle mainBundle] pathForResource:configName ofType:@"plist"];
    NSDictionary *configDic = [[NSDictionary alloc] initWithContentsOfFile:configPath];
    PLConfiguration *config = [[self alloc] initWithDictionary:configDic];
    return config;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        [self parseConfigWithDictionary:dic];
    }
    return self;
}

- (void)parseConfigWithDictionary:(NSDictionary *)dic {
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *valueDic = (NSDictionary *)obj;
            [self parseConfigWithDictionary:valueDic];
        } else {
            NSString *keyStr = (NSString *)key;
            NSString *camelKeyStr = [[keyStr substringToIndex:1].lowercaseString stringByAppendingString:[keyStr substringFromIndex:1]];
            if ([self respondsToSelector:NSSelectorFromString(camelKeyStr)]) {
                [self setValue:obj forKey:camelKeyStr];
            }
        }
    }];
}
@end
