//
//  PLPaymentManager.m
//  PhotoLibrary
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLPaymentManager.h"
#import "PLPaymentInfo.h"
#import "PLPaymentViewController.h"
#import "PLPaymentConfigModel.h"

#import "WXApi.h"
#import "WeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
#import <IapppayAlphaKit/IapppayAlphaKit.h>

static NSString *const kAlipaySchemeUrl = @"comjpyingyuan2016appalipayurlscheme";

@interface PLPaymentManager () <IapppayAlphaKitPayRetDelegate,WXApiDelegate>
@property (nonatomic,retain) PLPaymentInfo *paymentInfo;
@property (nonatomic,copy) PLPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) WeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@end

@implementation PLPaymentManager

DefineLazyPropertyInitialization(WeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

+ (instancetype)sharedManager {
    static PLPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
    [[PLPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        [[IapppayAlphaKit sharedInstance] setAppAlipayScheme:kAlipaySchemeUrl];
        [[IapppayAlphaKit sharedInstance] setAppId:[PLPaymentConfig sharedConfig].iappPayInfo.appid mACID:PL_CHANNEL_NO];
        [WXApi registerApp:[PLPaymentConfig sharedConfig].weixinInfo.appId];
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
//    [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)startPaymentWithType:(PLPaymentType)type
                     subType:(PLPaymentType)subType
                       price:(NSUInteger)price
                  forPayable:(id<PLPayable>)payable
           completionHandler:(PLPaymentCompletionHandler)handler
{
    if (type == PLPaymentTypeNone || (type == PLPaymentTypeIAppPay && subType == PLPaymentTypeNone)) {
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, nil);
        }
        return NO;
    }
    
    NSString *channelNo = PL_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    PLPaymentInfo *paymentInfo = [[PLPaymentInfo alloc] init];
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @(price);
    paymentInfo.contentId = payable.contentId;
    paymentInfo.contentType = payable.contentType;
    paymentInfo.payPointType = payable.payPointType;
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(PLPaymentStatusPaying);
    paymentInfo.reservedData = PL_PAYMENT_RESERVE_DATA;
    if (type == PLPaymentTypeWeChatPay) {
        paymentInfo.appId = [PLPaymentConfig sharedConfig].weixinInfo.appId;
        paymentInfo.mchId = [PLPaymentConfig sharedConfig].weixinInfo.mchId;
        paymentInfo.signKey = [PLPaymentConfig sharedConfig].weixinInfo.signKey;
        paymentInfo.notifyUrl = [PLPaymentConfig sharedConfig].weixinInfo.notifyUrl;
    }
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = handler;
    
    BOOL success = YES;
    if (type == PLPaymentTypeWeChatPay) {
        @weakify(self);
        [[WeChatPayManager sharedInstance] startWithPayment:paymentInfo completionHandler:^(PAYRESULT payResult) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
    } else if (type == PLPaymentTypeIAppPay) {
        NSDictionary *paymentTypeMapping = @{@(PLPaymentTypeAlipay):@(IapppayAlphaKitAlipayPayType),
                                             @(PLPaymentTypeWeChatPay):@(IapppayAlphaKitWeChatPayType)};
        NSNumber *payType = paymentTypeMapping[@(subType)];
        if (!payType) {
            return NO;
        }
        
        IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
        order.appId = [PLPaymentConfig sharedConfig].iappPayInfo.appid;
        order.cpPrivateKey = [PLPaymentConfig sharedConfig].iappPayInfo.privateKey;
        order.cpOrderId = orderNo;
#ifdef DEBUG
        order.waresId = @"2";
#else
        order.waresId = [PLPaymentConfig sharedConfig].iappPayInfo.waresid.stringValue;
#endif
        order.price = [NSString stringWithFormat:@"%.2f", price/100.];
        order.appUserId = [PLUtil userId] ?: @"UnregisterUser";
        order.cpPrivateInfo = PL_PAYMENT_RESERVE_DATA;
        
        NSString *trandData = [order getTrandData];
        success = [[IapppayAlphaKit sharedInstance] makePayForTrandInfo:trandData
                                                          payMethodType:payType.unsignedIntegerValue
                                                            payDelegate:self];
    } else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, self.paymentInfo);
        }
    }
    
    return success;
}

- (void)checkPayment {
    NSArray<PLPaymentInfo *> *payingPaymentInfos = [PLUtil payingPaymentInfos];
    [payingPaymentInfos enumerateObjectsUsingBlock:^(PLPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PLPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
        if (paymentType == PLPaymentTypeWeChatPay) {
            if (obj.appId.length == 0 || obj.mchId.length == 0 || obj.signKey.length == 0 || obj.notifyUrl.length == 0) {
                obj.appId = [PLPaymentConfig sharedConfig].weixinInfo.appId;
                obj.mchId = [PLPaymentConfig sharedConfig].weixinInfo.mchId;
                obj.signKey = [PLPaymentConfig sharedConfig].weixinInfo.signKey;
                obj.notifyUrl = [PLPaymentConfig sharedConfig].weixinInfo.notifyUrl;
            }
            
            [self.wechatPayOrderQueryRequest queryPayment:obj withCompletionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    PLPaymentViewController *paymentVC = [PLPaymentViewController sharedPaymentVC];
                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
                }
            }];
        }
    }];
}

#pragma mark - IapppayAlphaKitPayRetDelegate

- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode resultInfo:(NSDictionary *)resultInfo {
    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(PAYRESULT_SUCCESS),
                                           @(IapppayAlphaKitPayRetFailedCode):@(PAYRESULT_FAIL),
                                           @(IapppayAlphaKitPayRetCancelCode):@(PAYRESULT_ABANDON)};
    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
    if (!paymentResult) {
        paymentResult = @(PAYRESULT_UNKNOWN);
    }
    
    if (self.completionHandler) {
        self.completionHandler(paymentResult.integerValue, self.paymentInfo);
    }
}

#pragma mark - WeChat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PAYRESULT payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = PAYRESULT_ABANDON;
        } else if (resp.errCode == WXSuccess) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}
@end
