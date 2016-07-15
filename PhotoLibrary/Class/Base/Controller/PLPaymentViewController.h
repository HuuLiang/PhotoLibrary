//
//  PLPaymentViewController.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLBaseViewController.h"
#import "PLPayable.h"

@interface PLPaymentViewController : PLBaseViewController
@property (nonatomic)NSString *appleProductId;//内购
@property (nonatomic)PLPayPointType payPointType;//计费点

+ (instancetype)sharedPaymentVC;

/**在哪个界面上显示支付弹窗*/
- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable withCompletionHandler:(PLCompletionHandler)handler;
- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable withBeginAction:(PLAction)beginAction completionHandler:(PLCompletionHandler)handler;
- (void)hidePayment;

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(PLPaymentInfo *)paymentInfo;
@end
