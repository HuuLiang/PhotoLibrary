//
//  PLWeChatPayQueryOrderRequest.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLWeChatPayQueryOrderRequest.h"
#import "payRequsestHandler.h"
#import "WXUtil.h"

static NSString *const kWeChatPayQueryOrderUrlString = @"https://api.mch.weixin.qq.com/pay/orderquery";
static NSString *const kSuccessString = @"SUCCESS";

@implementation PLWeChatPayQueryOrderRequest

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(PLWeChatPayQueryOrderCompletionHandler)handler {
    
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    
    NSMutableDictionary *params = @{@"appid":[PLConfig sharedConfig].weChatPayAppId,
                             @"mch_id":[PLConfig sharedConfig].weChatPayMchId,
                             @"out_trade_no":orderNo,
                                    @"nonce_str":noncestr}.mutableCopy;
    //创建支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] init];
    //初始化支付签名对象
    [req init:[PLConfig sharedConfig].weChatPayAppId mch_id:[PLConfig sharedConfig].weChatPayMchId];
    //设置密钥
    [req setKey:[PLConfig sharedConfig].weChatPayPrivateKey];
    //设置回调URL
    [req setNotifyUrl:[PLConfig sharedConfig].weChatPayNotifyURL];
    
    NSString *package = [req genPackage:params];
    NSData *data =[WXUtil httpSend:kWeChatPayQueryOrderUrlString method:@"POST" data:package];

    XMLHelper *xml  = [[XMLHelper alloc] init];
    
    //开始解析
    [xml startParse:data];
    
    NSMutableDictionary *resParams = [xml getDict];
    self.return_code = resParams[@"return_code"];
    self.result_code = resParams[@"result_code"];
    self.trade_state = resParams[@"trade_state"];
    self.total_fee = ((NSString *)resParams[@"total_fee"]).integerValue / 100;
    
    if (handler) {
        handler([self.return_code isEqualToString:kSuccessString] && [self.result_code isEqualToString:kSuccessString], self.trade_state, self.total_fee);
    }
    return YES;
}
@end
