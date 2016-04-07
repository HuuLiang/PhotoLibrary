//
//  KbPaymentManager.h
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLProgram;

typedef void (^KbPaymentCompletionHandler)(PAYRESULT payResult, PLPaymentInfo *paymentInfo);

@interface KbPaymentManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;
- (BOOL)startPaymentWithType:(PLPaymentType)type
                     subType:(PLPaymentType)subType
                       price:(NSUInteger)price
                  forProgram:(id<PLPayable>)program
           completionHandler:(KbPaymentCompletionHandler)handler;

- (void)handleOpenURL:(NSURL *)url;
- (void)checkPayment;

@end
