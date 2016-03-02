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

+ (instancetype)sharedPaymentVC;

/**在哪个界面上显示支付弹窗*/
- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable withCompletionHandler:(PLPaymentCompletionHandler)handler;
- (void)hidePayment;

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(PLPaymentInfo *)paymentInfo;
@end
