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

- (void)popupPaymentInView:(UIView *)view forPayable:(id<PLPayable>)payable;
- (void)hidePayment;

@end
