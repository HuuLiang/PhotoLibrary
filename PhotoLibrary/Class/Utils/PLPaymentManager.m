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
#import "WeChatPayManager.h"
#import "PLWeChatPayQueryOrderRequest.h"
#import "AlipayManager.h"
#import <AlipaySDK/AlipaySDK.h>



//#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
//#import <IapppayAlphaKit/IapppayAlphaKit.h>

//static NSString *const kAlipaySchemeUrl = @"comjpyingyuan2016appalipayurlscheme";

@interface PLPaymentManager () <WXApiDelegate>
@property (nonatomic,retain) PLPaymentInfo *paymentInfo;
@property (nonatomic,copy) PLPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) PLWeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;

@property (nonatomic,retain)PLPaymentInfo *applepaymentInfo;//内购
@property (nonatomic)NSString *applePayProductId;

@end

@implementation PLPaymentManager

DefineLazyPropertyInitialization(PLWeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

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
        //        [[IapppayAlphaKit sharedInstance] setAppAlipayScheme:kAlipaySchemeUrl];
        //        [[IapppayAlphaKit sharedInstance] setAppId:[PLPaymentConfig sharedConfig].iappPayInfo.appid mACID:PL_CHANNEL_NO];
        [WXApi registerApp:[PLPaymentConfig sharedConfig].weixinInfo.appId];
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    //    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
    [WXApi handleOpenURL:url delegate:self];
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        [[AlipayManager shareInstance] sendNotificationByResult:resultDic];
    }];
}

- (BOOL)startPaymentWithType:(PLPaymentType)type
                     subType:(PLPaymentType)subType
                       price:(NSUInteger)price
                  forPayable:(id<PLPayable>)payable
           applePayProductId:(NSString *)applePayProductId
                payPointType:(PLPayPointType)payPointType
           completionHandler:(PLPaymentCompletionHandler)handler
{
    if (type == PLPaymentTypeNone || (type == PLPaymentTypeIAppPay && subType == PLPaymentTypeNone)) {
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, nil);
        }
        return NO;
    }
#if DEBUG
    price = 1;
#endif
    NSString *channelNo = PL_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    PLPaymentInfo *paymentInfo = [[PLPaymentInfo alloc] init];
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @(price);
    paymentInfo.contentId = payable.contentId;
    paymentInfo.contentType = payable.contentType;
    paymentInfo.payPointType = @(payPointType);
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
        DLog(@"%@",[PLPaymentConfig sharedConfig].weixinInfo);
        @weakify(self);
        //        [[WeChatPayManager sharedInstance] startWithPayment:paymentInfo completionHandler:^(PAYRESULT payResult) {
        //            @strongify(self);
        //            if (self.completionHandler) {
        //                self.completionHandler(payResult, self.paymentInfo);
        //            }
        //        }];
        
        [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo price:price completionHandler:^(PAYRESULT payResult) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(payResult,paymentInfo);
            }
        }];
        
    }else if (type == PLPaymentTypeAlipay){
        @weakify(self);
        [[AlipayManager shareInstance] startAlipay:orderNo price:price withResult:^(PAYRESULT result, Order *order) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(result,paymentInfo);
            }
        }];
        
    }else if (type == PLPaymentTypeApplePay){
        self.applepaymentInfo = paymentInfo;
        self.applePayProductId = applePayProductId;
        [self getPriceWithPaymentInfo:paymentInfo applePayProductId:applePayProductId];
        
    }  else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, self.paymentInfo);
        }
    }
    
    return success;
}

- (void)getPriceWithPaymentInfo:(PLPaymentInfo *)paymentInfo applePayProductId:(NSString *)applePayProductId{
    if ([PLApplePay shareApplePay].isGettingPriceInfo) {
        
        [self performSelector:@selector(getPriceWithPaymentInfo:applePayProductId:) withObject:nil afterDelay:1.];
        [self performSelector:@selector(getPriceInfoError) withObject:nil afterDelay:3.0];
        
    }
    @weakify(self);
    [[PLApplePay shareApplePay] payWithProductionId:self.applePayProductId];
    [[UIApplication sharedApplication].keyWindow pl_beginLoading];
    [PLApplePay shareApplePay].appPayBack = ^(SKPaymentTransactionState paystates){
        @strongify(self);
        //            paymentInfo.orderPrice =
        PAYRESULT payResult;
        switch (paystates) {
            case SKPaymentTransactionStateFailed:
                payResult = PAYRESULT_FAIL;
                break;
            case SKPaymentTransactionStatePurchased:
                payResult = PAYRESULT_SUCCESS;
                break;
                //                    case SKPaymentTransactionStateFailed:
                //                        payResult = PAYRESULT_FAIL;
                //                        break;
                
            default:
                payResult = PAYRESULT_UNKNOWN;
                break;
        }
        
        if (self.completionHandler) {
            self.completionHandler(payResult,_applepaymentInfo);
            [[UIApplication sharedApplication].keyWindow pl_endLoading];
        }
    };
    
    
}


- (void)getPriceInfoError {
    if ([PLUtil isApplePay] && [PLApplePay shareApplePay].isGettingPriceInfo) {
        [[UIApplication sharedApplication].keyWindow pl_endLoading];
    }
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
            
            //            [self.wechatPayOrderQueryRequest queryPayment:obj withCompletionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
            //                if ([trade_state isEqualToString:@"SUCCESS"]) {
            //                    PLPaymentViewController *paymentVC = [PLPaymentViewController sharedPaymentVC];
            //                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
            //                }
            //            }];
            PLPaymentViewController *paymentVC = [PLPaymentViewController sharedPaymentVC];
            [self.wechatPayOrderQueryRequest queryOrderWithNo:obj.orderId completionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    //                          [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
                }else {
                    [paymentVC notifyPaymentResult:PAYRESULT_FAIL withPaymentInfo:obj];
                }
            }];
        }else {
            obj.paymentResult = @(PAYRESULT_FAIL);
            obj.paymentStatus = @(PLPaymentStatusNotProcessed);
            [obj save];
        }
        
    }];
}


#pragma mark - WeChat delegate

//- (void)onReq:(BaseReq *)req {
//    
//}

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
