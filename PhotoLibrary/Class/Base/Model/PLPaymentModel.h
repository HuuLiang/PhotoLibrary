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

- (void)startRetryingToCommitUnprocessedOrders;
- (void)commitUnprocessedOrders;
- (BOOL)commitPaymentInfo:(PLPaymentInfo *)paymentInfo;


@end
