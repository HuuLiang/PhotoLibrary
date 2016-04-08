//
//  WeChatPayManager.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WeChatPayCompletionHandler)(PAYRESULT payResult);

@interface WeChatPayManager : NSObject

+ (instancetype)sharedInstance;
/**
 *  新的API
 */
- (void)startWithPayment:(PLPaymentInfo *)paymentInfo completionHandler:(WeChatPayCompletionHandler)handler;
- (void)sendNotificationByResult:(PAYRESULT)result;
@end
