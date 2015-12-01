//
//  PLUserAccessModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLUserAccessModel.h"

@implementation PLUserAccessModel

+ (Class)responseClass {
    return [NSString class];
}

+ (instancetype)sharedModel {
    static PLUserAccessModel *_theInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _theInstance = [[PLUserAccessModel alloc] init];
    });
    return _theInstance;
}

- (BOOL)requestUserAccess {
    NSString *userId = [PLUtil userId];
    if (!userId) {
        return NO;
    }
    
    @weakify(self);
    BOOL ret = [super requestURLPath:[PLConfig sharedConfig].userAccessURLPath
                         withParams:@{@"userId":userId,@"accessId":[PLUtil accessId]}
                    responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        BOOL success = NO;
        if (respStatus == PLURLResponseSuccess) {
            NSString *resp = self.response;
            success = [resp isEqualToString:@"SUCCESS"];
            if (success) {
                DLog(@"Record user access!");
            }
        }
    }];
    return ret;
}

@end
