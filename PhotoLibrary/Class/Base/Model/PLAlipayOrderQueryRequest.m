//
//  PLAlipayOrderQueryRequest.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLAlipayOrderQueryRequest.h"

static NSString *const kAlipayOrderQueryUrlString = @"https://openapi.alipay.com/gateway.do";

@implementation PLAlipayOrderQueryResponse

@end

@implementation PLAlipayOrderQueryRequest

+ (Class)responseClass {
    return [PLAlipayOrderQueryResponse class];
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(PLAlipayOrderQueryCompletionHandler)handler {
    NSDateFormatter *dateFormmatter = [[NSDateFormatter alloc] init];
    NSDictionary *params = @{@"app_id":[PLConfig sharedConfig].alipayPID,
                             @"method":@"alipay.trade.pay",
                             @"charset":@"utf-8",
                             @"sign_type":@"RSA",
                             @"sign":[PLConfig sharedConfig].alipayPrivateKey,
                             @"timestamp":[dateFormmatter stringFromDate:[NSDate date]],
                             @"version":@"1.0",
                             @"biz_content":@""};
    BOOL success = [self requestURLPath:kAlipayOrderQueryUrlString
                             withParams:params
                        responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
    {
        
    }];
    return success;
}

@end
