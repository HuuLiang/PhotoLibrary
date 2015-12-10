//
//  PLPaymentViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPaymentViewController.h"
#import "PLPaymentPopView.h"
#import "PLSystemConfigModel.h"
#import "PLPaymentModel.h"
#import <objc/runtime.h>
#import "PLProgram.h"
#import "AlipayManager.h"
#import "WeChatPayManager.h"

@interface PLPaymentViewController ()
@property (nonatomic,retain) PLPaymentPopView *popView;
@property (nonatomic) NSNumber *payAmount;

@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
@property (nonatomic,assign) id<PLPayable> payableObject;
@end

@implementation PLPaymentViewController
@synthesize paymentTypeMap = _paymentTypeMap;

+ (instancetype)sharedPaymentVC {
    static PLPaymentViewController *_sharedPaymentVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPaymentVC = [[PLPaymentViewController alloc] init];
    });
    return _sharedPaymentVC;
}

- (PLPaymentPopView *)popView {
    if (_popView) {
        return _popView;
    }
    
    @weakify(self);
    _popView = [[PLPaymentPopView alloc] init];
    _popView.paymentAction = ^(PLPaymentType type) {
        @strongify(self);
        if (!self.payAmount) {
            [[PLHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
            return ;
        }
        
        [self pay:self.payableObject withPaymentType:type];
    };
    _popView.backAction = ^{
        @strongify(self);
        [self hidePayment];
    };
    return _popView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.popView];
    {
        [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.size.mas_equalTo(self.popView.contentSize);
        }];
    }
}

- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.payAmount = nil;
    self.payableObject = payable;
    self.popView.usage = [payable payableUsage];
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    [view addSubview:self.view];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
    }];
    
    [self fetchPayAmount];
}

- (void)fetchPayAmount {
    @weakify(self);
    PLSystemConfigModel *systemConfigModel = [PLSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (success) {
            self.payAmount = @(systemConfigModel.payAmount);
        }
    }];
}

- (void)setPayAmount:(NSNumber *)payAmount {
#ifdef DEBUG
    payAmount = @(0.01);
#endif
    _payAmount = payAmount;
    self.popView.showPrice = payAmount;
}

- (void)hidePayment {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)pay:(id<PLPayable>)payable withPaymentType:(PLPaymentType)paymentType {
    @weakify(self);
    NSString *channelNo = [PLConfig sharedConfig].channelNo;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    [PLUtil setPayingOrderWithOrderNo:orderNo paymentType:paymentType];

    NSString *contentId = payable.contentId.stringValue ?: @"";
    NSString *contentType = payable.contentType.stringValue ?: @"";
    NSString *payPointType = payable.payPointType.stringValue ?: @"999";
    NSNumber *price = payable.payableFee;
    
    void (^PayResultBack)(PAYRESULT result) = ^(PAYRESULT result) {
        @strongify(self);

        if (result == PAYRESULT_SUCCESS) {
            [PLUtil setPaidPendingWithOrder:@[orderNo,
                                              payable.payableFee.stringValue,
                                              payable.contentId.stringValue ?: @"",
                                              payable.contentType.stringValue ?: @"",
                                              payable.payPointType.stringValue ?: @"999"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentNotificationName object:nil];
            [self hidePayment];
        } else if (result == PAYRESULT_FAIL) {
            [[PLHudManager manager] showHudWithText:@"支付失败"];
        } else if (result == PAYRESULT_ABANDON) {
            [[PLHudManager manager] showHudWithText:@"支付取消"];
        }

        [[PLPaymentModel sharedModel] paidWithOrderId:orderNo
                                                price:price
                                               result:result
                                            contentId:contentId
                                          contentType:contentType
                                         payPointType:payPointType
                                          paymentType:paymentType
                                    completionHandler:^(BOOL success){
            if (success && result == PAYRESULT_SUCCESS) {
                [PLPaymentUtil setPaidForPayable:payable];
            }
        }];
    };
    
    if (paymentType == PLPaymentTypeAlipay) {
        [[AlipayManager shareInstance] startAlipay:orderNo
                                             price:@(price.doubleValue/100).stringValue
                                        withResult:^(PAYRESULT result, Order *order) {
                                            PayResultBack(result);
                                        }];
    } else if (paymentType == PLPaymentTypeWeChatPay) {
        [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo
                                                               price:price.doubleValue / 100
                                                   completionHandler:^(PAYRESULT payResult) {
                                                       PayResultBack(payResult);
                                                   }];
    }
    
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
//    IPNPreSignMessageUtil *preSign =[[IPNPreSignMessageUtil alloc] init];
//    preSign.consumerId = [PLConfig sharedConfig].channelNo;
//    preSign.mhtOrderNo = orderNo;
//    preSign.mhtOrderName = @"家庭影院";//[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ?: @"家庭影院";
//    preSign.mhtOrderType = kPayNowNormalOrderType;
//    preSign.mhtCurrencyType = kPayNowRMBCurrencyType;
//    preSign.mhtOrderAmt = [NSString stringWithFormat:@"%ld", @(price*100).unsignedIntegerValue];
//    preSign.mhtOrderDetail = [preSign.mhtOrderName stringByAppendingString:@"终身会员"];
//    preSign.mhtOrderStartTime = [dateFormatter stringFromDate:[NSDate date]];
//    preSign.mhtCharset = kPayNowDefaultCharset;
//    preSign.payChannelType = ((NSNumber *)self.paymentTypeMap[@(paymentType)]).stringValue;
    
//    [[PLPaymentSignModel sharedModel] signWithPreSignMessage:preSign completionHandler:^(BOOL success, NSString *signedData) {
//        @strongify(self);
//        if (success) {
//            self.paymentInfo = preSign;
//            [IpaynowPluginApi pay:signedData AndScheme:[PLConfig sharedConfig].payNowScheme viewController:self delegate:self];
//        } else {
//            [[PLHudManager manager] showHudWithText:@"服务器获取签名失败！"];
//        }
//    }];
}

//- (NSDictionary *)paymentTypeMap {
//    if (_paymentTypeMap) {
//        return _paymentTypeMap;
//    }
//    
//    _paymentTypeMap = @{@(PLPaymentTypeAlipay):@(PayNowChannelTypeAlipay),
//                          @(PLPaymentTypeWeChatPay):@(PayNowChannelTypeWeChatPay),
//                          @(PLPaymentTypeUPPay):@(PayNowChannelTypeUPPay)};
//    return _paymentTypeMap;
//}

//- (PLPaymentType)paymentTypeFromPayNowType:(PayNowChannelType)type {
//    __block PLPaymentType retType = PLPaymentTypeNone;
//    [self.paymentTypeMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        if ([(NSNumber *)obj isEqualToNumber:@(type)]) {
//            retType = ((NSNumber *)key).unsignedIntegerValue;
//            *stop = YES;
//            return ;
//        }
//    }];
//    return retType;
//}
//
//- (PayNowChannelType)payNowTypeFromPaymentType:(PLPaymentType)type {
//    return ((NSNumber *)self.paymentTypeMap[@(type)]).unsignedIntegerValue;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo {
//    NSLog(@"PayResult:%ld\nerrorCode:%@\nerrorInfo:%@", result,errCode,errInfo);
//    
//    if (result == IPNPayResultSuccess) {
//        
//        [PLUtil setPaidPendingWithOrder:@[self.paymentInfo.mhtOrderNo,
//                                          self.paymentInfo.mhtOrderAmt,
//                                          self.programToPayFor.programId.stringValue,
//                                          self.programToPayFor.type.stringValue,
//                                          self.programToPayFor.payPointType.stringValue]];
//        [self hidePayment];
//        [[PLHudManager manager] showHudWithText:@"支付成功"];
//        
//        
//        [[PLPaymentModel sharedModel] paidWithOrderId:self.paymentInfo.mhtOrderNo
//                                                price:self.paymentInfo.mhtOrderAmt
//                                               result:result
//                                            contentId:self.programToPayFor.programId.stringValue
//                                          contentType:self.programToPayFor.type.stringValue
//                                         payPointType:self.programToPayFor.payPointType.stringValue
//                                          paymentType:[self paymentTypeFromPayNowType:self.paymentInfo.payChannelType.integerValue]
//                                    completionHandler:^(BOOL success){
//            if (success && result == PAYRESULT_SUCCESS) {
//                [PLUtil setPaid];
//            }
//        }];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPaidNotificationName object:nil];
//    }
//}

@end
