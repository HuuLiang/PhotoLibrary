//
//  PLPaymentModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLPaymentInfo.h"

typedef void (^PLPaidCompletionHandler)(BOOL success);

@interface PLPaymentModel : PLEncryptedURLRequest

+ (instancetype)sharedModel;
/**再次处理提交未成功的订单*/
- (void)startRetryingToCommitUnprocessedOrders;
/**提交未处理成功的订单*/
- (void)commitUnprocessedOrders;
/**提交支付信息*/
- (BOOL)commitPaymentInfo:(PLPaymentInfo *)paymentInfo;


@end
