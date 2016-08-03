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
#import "PLPaymentManager.h"
#import "PLPaymentConfig.h"


@interface PLPaymentViewController ()
@property (nonatomic,retain) PLPaymentPopView *popView;

@property (nonatomic,retain) PLPaymentInfo *PLpaymentInfo;

@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
@property (nonatomic,assign) id<PLPayable> payableObject;

@property (nonatomic,copy) PLAction beginAction;
@property (nonatomic,copy) PLCompletionHandler completionHandler;

@property (nonatomic,strong)UIView *currentView;
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
    
    @weakify(self);
    void (^Pay)(PLPaymentType type, PLPaymentType subType,NSString *applePayProductId) = ^(PLPaymentType type, PLPaymentType subType,NSString *applePayProductId)
    {
        @strongify(self);
        [self pay:self.payableObject withPaymentType:type andSubPaymentType:subType applePayProductId:applePayProductId];
        [self hidePayment];
    };
    
    _popView = [[PLPaymentPopView alloc] init];
    
    if ([PLUtil isApplePay]) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"applepay"] title:@"苹果内购" available:YES action:^(id sender) {
            @strongify(self);
            if (self.beginAction) {
                self.beginAction(self);
            }
            Pay(PLPaymentTypeApplePay,NSNotFound,self.appleProductId);
            
        }];
    }else {
        if ([PLPaymentConfig sharedConfig].weixinInfo) {
            BOOL useBuildInWeChatPay = [PLPaymentConfig sharedConfig].weixinInfo != nil;
            [_popView addPaymentWithImage:[UIImage imageNamed:@"wenxin"] title:@"微信支付" available:YES action:^(id sender) {
                @strongify(self);
                if (self.beginAction) {
                    self.beginAction(self);
                }
                Pay(useBuildInWeChatPay?PLPaymentTypeWeChatPay:PLPaymentTypeIAppPay, useBuildInWeChatPay?PLPaymentTypeNone:PLPaymentTypeWeChatPay,nil);
            }];
        }
        
        if ([PLPaymentConfig sharedConfig].alipayInfo) {
            BOOL useBuildInAlipay = [PLPaymentConfig sharedConfig].alipayInfo != nil;
            [_popView addPaymentWithImage:[UIImage imageNamed:@"zhifubao-0"] title:@"支付宝支付" available:YES action:^(id sender) {
                @strongify(self);
                if (self.beginAction) {
                    self.beginAction(self);
                }
                Pay(useBuildInAlipay?PLPaymentTypeAlipay:PLPaymentTypeIAppPay, useBuildInAlipay?PLPaymentTypeNone:PLPaymentTypeAlipay,nil);
            }];
        }
    }
    _popView.closeAction = ^(id sender){
        @strongify(self);
        [self hidePayment];
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
            const CGFloat width = kScreenWidth * 0.95;
            make.size.mas_equalTo(CGSizeMake(width, [self.popView viewHeightRelativeToWidth:width]));
        }];
    }
}
/**弹出支付界面*/
- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable withCompletionHandler:(PLCompletionHandler)handler {
    return [self popupPaymentInView:view forPayable:payable withBeginAction:nil completionHandler:handler];
}

- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable withBeginAction:(PLAction)beginAction completionHandler:(PLCompletionHandler)handler {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.beginAction = beginAction;
    self.completionHandler = handler;
    self.payableObject = payable;
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    UIView *hudView = [PLHudManager manager].hudView;
    if (view == [UIApplication sharedApplication].keyWindow) {
        [view insertSubview:self.view belowSubview:hudView];
    } else {
        [view addSubview:self.view];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)setPayableObject:(id<PLPayable>)payableObject {
    _payableObject = payableObject;
    
//    self.popView.showPrice = @([payableObject payableFee].doubleValue / 100.);
//    self.popView.showPrice = self.payPointType == PLPayPointTypePictureVIP ? @([PLSystemConfigModel sharedModel].photoPrice/100.) :@([PLSystemConfigModel sharedModel].videoPrice/100.);
    
    self.popView.showPrice = [PLUtil isAppleStore] ? nil : @([PLSystemConfigModel sharedModel].photoPrice/100.);
    
//    NSDictionary *headerImages = @{@(PLPaymentForPhotoChannel):[PLUtil isAppleStore] ? @"appstore_image" : @"payment_channel",
//                                   @(PLPaymentForPhotoAlbum):[PLUtil isAppleStore] ? @"appstore_image" : @"payment_album",
//                                   @(PLPaymentForVideo):[PLUtil isAppleStore] ? @"appstore_image" : @"payment_video"};
//    self.popView.headerImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:headerImages[@(payableObject.payableUsage)] ofType:@"jpg"]];
    
//    NSString *imageName = [PLUtil isAppleStore] ? @"appstore_image.jpg" : @"payment_album.jpg";
    if ([PLUtil isAppleStore] ) {
        
        self.popView.headerImage =  @"appstore_image.jpg";
    }else {
    
        self.popView.headerImage = [PLSystemConfigModel sharedModel].payImage;
    }
    self.popView.priceColor = [payableObject payableUsage] == PLPaymentForPhotoChannel ? [UIColor yellowColor] : [UIColor redColor];
}

- (void)hidePayment {
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        self.beginAction = nil;
    }];
}

/**
 *  支付
 *
 *  @param payable          遵守id<PLPayable>协议的模块
 *  @param paymentType 首选支付类型（比如本地的微信支付、微信支付/爱贝支付）
 *  @param subType     支付方式子类型（微信支付、支付宝支付）
 */
- (void)pay:(id<PLPayable>)payable withPaymentType:(PLPaymentType)paymentType andSubPaymentType:(PLPaymentType)subType applePayProductId:(NSString *)applePayProductId{
    @weakify(self);
//    NSUInteger price = [[payable payableFee] integerValue];
    NSUInteger price = self.payPointType == PLPayPointTypePictureVIP ? [PLSystemConfigModel sharedModel].photoPrice :[PLSystemConfigModel sharedModel].videoPrice;
    [[PLPaymentManager sharedManager] startPaymentWithType:paymentType
                                                   subType:subType
                                                     price:price
                                                forPayable:payable
                                         applePayProductId:applePayProductId
                                              payPointType:self.payPointType
                                         completionHandler:^(PAYRESULT payResult, PLPaymentInfo *paymentInfo)
     {
         @strongify(self);
         [self notifyPaymentResult:payResult withPaymentInfo:paymentInfo];
     }];
}


/**提交支付结果*/
/**
 *  支付完成之后提示并保存支付结果到本地
 *
 *  @param result      支付结果不管 成功、失败、还是取消
 *  @param paymentInfo 支付参数
 */
- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(PLPaymentInfo *)paymentInfo {
    //    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    //    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    paymentInfo.paymentResult = @(result);
    paymentInfo.paymentStatus = @(PLPaymentStatusNotProcessed);
    paymentInfo.paymentTime = [PLUtil currentDateString];
    [paymentInfo save];
    
    if (result == PAYRESULT_SUCCESS) {//如果支付成功
//        [PLPaymentUtil setPaidForPayable:self.payableObject];//设置这个东西已经支付过
        [[PLHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentNotificationName object:nil];//通知支付成功
        [PLStatistics statPayment:self.payableObject];//友盟统计
    } else if (result == PAYRESULT_ABANDON) {
        [[PLHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[PLHudManager manager] showHudWithText:@"支付失败"];
    }
    
    if (self.completionHandler) {
        self.completionHandler(result==PAYRESULT_SUCCESS, paymentInfo);//激活支付完成
        self.completionHandler = nil;
    }
    //    [self.currentView pl_endLoading];
    [[UIApplication sharedApplication].keyWindow pl_endLoading];
    //提交支付信息
    [[PLPaymentModel sharedModel] commitPaymentInfo:paymentInfo];
    
}

@end
