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
#import "KbPaymentManager.h"
#import "PLPaymentConfig.h"
@interface PLPaymentViewController ()
@property (nonatomic,retain) PLPaymentPopView *popView;

@property (nonatomic,retain) PLPaymentInfo *PLpaymentInfo;

@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
@property (nonatomic,assign) id<PLPayable> payableObject;

@property (nonatomic,copy) PLPaymentCompletionHandler completionHandler;
@end

@implementation PLPaymentViewController
@synthesize paymentTypeMap = _paymentTypeMap;

/**初始化支付界面控制器*/
+ (instancetype)sharedPaymentVC {
    static PLPaymentViewController *_sharedPaymentVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPaymentVC = [[PLPaymentViewController alloc] init];
    });
    return _sharedPaymentVC;
}

/**支付界面弹框*/
- (PLPaymentPopView *)popView {
    if (_popView) {
        return _popView;
    }
    
   
    _popView = [[PLPaymentPopView alloc] init];
    
    /**
     *  支付button点击回调
     */
     @weakify(self);
    _popView.paymentAction = ^(PLPaymentType type ,PLPaymentType subType) {
        @strongify(self);

        [self pay:self.payableObject withPaymentType:type andSubPaymentType:subType];
       
    };
    
    
    /**返回block激活后进来*/
    _popView.backAction = ^{
        @strongify(self);
        
        [self hidePayment]; //隐藏支付弹窗

        if (self.completionHandler) {
            self.completionHandler(NO);
        }
    };
    
    return _popView;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.popView];

    {
        [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.size.mas_equalTo(self.popView.contentSize);
        }];
    }
}
/**弹出支付界面*/
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

/**
 *  支付
 *
 *  @param payable          遵守id<PLPayable>协议的模块
 *  @param paymentType 首选支付类型（比如本地的微信支付、微信支付/爱贝支付）
 *  @param subType     支付方式子类型（微信支付、支付宝支付）
 */
- (void)pay:(id<PLPayable>)payable withPaymentType:(PLPaymentType)paymentType andSubPaymentType:(PLPaymentType)subType{
    @weakify(self);
    
        NSUInteger price = [[payable payableFee] integerValue];
    
    /**
     *  重新调整支付方式
     */
    void (^callPay)(PLPaymentType,PLPaymentType) = ^(PLPaymentType type,PLPaymentType subType){
        
        [[KbPaymentManager sharedManager] startPaymentWithType:type subType:paymentType price:price forProgram:payable completionHandler:^(PAYRESULT payResult, PLPaymentInfo *paymentInfo) {
            @strongify(self)
            
            [self notifyPaymentResult:payResult withPaymentInfo:self.PLpaymentInfo];
            
        }];
     };
    
    if (([PLPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & KbIAppPayTypeWeChat)
        ) {//爱贝微信支付

        callPay(PLPaymentTypeIAppPay,PLPaymentTypeWeChatPay);

    }else  if (([PLPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & KbIAppPayTypeAlipay)
               ) {//爱贝支付宝支付
        
        callPay(PLPaymentTypeIAppPay,PLPaymentTypeAlipay);
        
    }else if([PLPaymentConfig sharedConfig].weixinInfo||[PLPaymentConfig sharedConfig].alipayInfo){//获取的是本地的 支付宝或者微信支付
    
        if (paymentType==PLPaymentTypeWeChatPay) {//本地微信
            
           callPay(PLPaymentTypeWeChatPay,PLPaymentTypeWeChatPay);
            
        }else if (paymentType==PLPaymentTypeAlipay){//本地支付宝
            
            [[PLHudManager manager] showHudWithText:@"无法获取支付信息"];
//               callPay(PLPaymentTypeAlipay,PLPaymentTypeAlipay);
        }
        
    }else{//没有获取任何支付数据
       [[PLHudManager manager] showHudWithText:@"无法获取支付信息"];
    }
}


/**提交支付结果*/
/**
 *  支付完成之后提示并保存支付结果到本地
 *
 *  @param result      支付结果不管 成功、失败、还是取消
 *  @param paymentInfo 支付参数
 */
- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(PLPaymentInfo *)paymentInfo {
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    paymentInfo.paymentResult = @(result);
    paymentInfo.paymentStatus = @(PLPaymentStatusNotProcessed);
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    if (result == PAYRESULT_SUCCESS) {//如果支付成功
        
        [PLPaymentUtil setPaidForPayable:self.payableObject];//设置这个东西已经支付过
        [self hidePayment];
        [[PLHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentNotificationName object:nil];//通知支付成功
        if (self.completionHandler) {
            self.completionHandler(YES);//激活支付完成
        }
        [PLStatistics statPayment:self.payableObject];//友盟统计
    } else if (result == PAYRESULT_ABANDON) {
        [[PLHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[PLHudManager manager] showHudWithText:@"支付失败"];
    }
    
    //提交支付信息
    [[PLPaymentModel sharedModel] commitPaymentInfo:paymentInfo];
    
}

//- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo {
//    NSLog(@"PayResult:%ld\nerrorCode:%@\nerrorInfo:%@", result,errCode,errInfo);
//    
//    PAYRESULT payResult = [self paymentResultFromPayNowResult:result];
//    [self notifyPaymentResult:payResult withPaymentInfo:self.PLpaymentInfo];
//}

@end
