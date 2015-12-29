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
#import "PLPaymentInfo.h"
#import "WeChatPayManager.h"

@interface PLPaymentViewController ()
@property (nonatomic,retain) PLPaymentPopView *popView;

@property (nonatomic,retain) PLPaymentInfo *PLpaymentInfo;


@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
@property (nonatomic,assign) id<PLPayable> payableObject;

@property (nonatomic,copy) PLPaymentCompletionHandler completionHandler;
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
        [self pay:self.payableObject withPaymentType:type];
    };
    _popView.backAction = ^{
        @strongify(self);
        [self hidePayment];
        
        if (self.completionHandler) {
            self.completionHandler(NO);
        }
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

- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable withCompletionHandler:(PLPaymentCompletionHandler)handler {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.completionHandler = handler;
    self.payableObject = payable;
    self.popView.usage = [payable payableUsage];
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    if (view == [UIApplication sharedApplication].keyWindow) {
        [view insertSubview:self.view belowSubview:[PLHudManager manager].hudView];
    } else {
        [view addSubview:self.view];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
    }];
    
//    [self fetchPayAmount];
}

//- (void)fetchPayAmount {
//    @weakify(self);
//    PLSystemConfigModel *systemConfigModel = [PLSystemConfigModel sharedModel];
//    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
//        @strongify(self);
//        if (success) {
//            self.payAmount = @(systemConfigModel.payAmount);
//        }
//    }];
//}

- (void)setPayableObject:(id<PLPayable>)payableObject {
    _payableObject = payableObject;
    
    self.popView.showPrice = @([payableObject payableFee].doubleValue / 100.);
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
    
    PLPaymentInfo *paymentInfo = [[PLPaymentInfo alloc]init];
    paymentInfo.orderId =orderNo;
    paymentInfo.orderPrice=[payable payableFee];
    paymentInfo.contentId = [payable contentId];
    paymentInfo.paymentType = @(paymentType);
    paymentInfo.payPointType = [payable contentType];
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(PLPaymentStatusPaying);
    [paymentInfo save];
    self.PLpaymentInfo=paymentInfo;

    if (paymentType==PLPaymentTypeWeChatPay) {
        [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo price:[payable payableFee].unsignedIntegerValue completionHandler:^(PAYRESULT payResult) {
            @strongify(self);
            [self notifyPaymentResult:payResult withPaymentInfo:self.PLpaymentInfo];
        }];
    }else{
        [[PLHudManager manager] showHudWithText:@"无法获取支付信息"];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//        IPNPreSignMessageUtil *preSign =[[IPNPreSignMessageUtil alloc] init];
//        preSign.consumerId = [PLConfig sharedConfig].channelNo;
//        preSign.mhtOrderNo = orderNo;
//        preSign.mhtOrderName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ?: @"家庭影院";
//        preSign.mhtOrderType = kPayNowNormalOrderType;
//        preSign.mhtCurrencyType = kPayNowRMBCurrencyType;
//#ifdef DEBUG
//        preSign.mhtOrderAmt = @"10";
//#else
//        preSign.mhtOrderAmt = [payable payableFee].stringValue;
//#endif
//        preSign.mhtOrderDetail = [preSign.mhtOrderName stringByAppendingString:@"终身会员"];
//        preSign.mhtOrderStartTime = [dateFormatter stringFromDate:[NSDate date]];
//        preSign.mhtCharset = kPayNowDefaultCharset;
//        preSign.payChannelType = ((NSNumber *)self.paymentTypeMap[@(paymentType)]).stringValue;
//        [[PLPaymentSignModel sharedModel] signWithPreSignMessage:preSign completionHandler:^(BOOL success, NSString *signedData) {
//            @strongify(self);
//            if (success && [PLPaymentSignModel sharedModel].appId.length > 0) {
//                [IpaynowPluginApi pay:signedData AndScheme:[PLConfig sharedConfig].payNowScheme viewController:self delegate:self];
//            } else {
//                [[PLHudManager manager] showHudWithText:@"无法获取支付信息"];
//            }
//        }];
    }
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
//
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

//- (PayNowChannelType)payNowTypeFromPaymentType:(PLPaymentType)type {
//    return ((NSNumber *)self.paymentTypeMap[@(type)]).unsignedIntegerValue;
//}
//
//- (PAYRESULT)paymentResultFromPayNowResult:(IPNPayResult)result {
//    NSDictionary *resultMap = @{@(IPNPayResultSuccess):@(PAYRESULT_SUCCESS),
//                                @(IPNPayResultFail):@(PAYRESULT_FAIL),
//                                @(IPNPayResultCancel):@(PAYRESULT_ABANDON),
//                                @(IPNPayResultUnknown):@(PAYRESULT_UNKNOWN)};
//    return ((NSNumber *)resultMap[@(result)]).unsignedIntegerValue;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(PLPaymentInfo *)paymentInfo {
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    paymentInfo.paymentResult = @(result);
    paymentInfo.paymentStatus = @(PLPaymentStatusNotProcessed);
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    if (result == PAYRESULT_SUCCESS) {
        [PLPaymentUtil setPaidForPayable:self.payableObject];
        [self hidePayment];
        [[PLHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentNotificationName object:nil];
        if (self.completionHandler) {
            self.completionHandler(YES);
        }
        [PLStatistics statPayment:self.payableObject];
    } else if (result == PAYRESULT_ABANDON) {
        [[PLHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[PLHudManager manager] showHudWithText:@"支付失败"];
    }
    
    [[PLPaymentModel sharedModel] commitPaymentInfo:paymentInfo];
    
}

//- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo {
//    NSLog(@"PayResult:%ld\nerrorCode:%@\nerrorInfo:%@", result,errCode,errInfo);
//    
//    PAYRESULT payResult = [self paymentResultFromPayNowResult:result];
//    [self notifyPaymentResult:payResult withPaymentInfo:self.PLpaymentInfo];
//}

@end
