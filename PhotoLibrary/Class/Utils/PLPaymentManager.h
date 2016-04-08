//
//  PLPaymentManager.h
//  PhotoLibrary
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPayable.h"

typedef void (^PLPaymentCompletionHandler)(PAYRESULT payResult, PLPaymentInfo *paymentInfo);

@interface PLPaymentManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;
- (BOOL)startPaymentWithType:(PLPaymentType)type
                     subType:(PLPaymentType)subType
                       price:(NSUInteger)price
                  forPayable:(id<PLPayable>)payable
           completionHandler:(PLPaymentCompletionHandler)handler;


- (void)handleOpenURL:(NSURL *)url;
- (void)checkPayment;

@end
