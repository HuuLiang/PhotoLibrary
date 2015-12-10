//
//  PLPaymentModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "Order.h"

typedef void (^PLPaidCompletionHandler)(BOOL success);

@interface PLPaymentModel : PLEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)processPendingOrder;
- (BOOL)paidWithOrderId:(NSString *)orderId
                  price:(NSNumber *)price
                 result:(NSInteger)result
              contentId:(NSString *)contentId
            contentType:(NSString *)contentType
           payPointType:(NSString *)payPointType
            paymentType:(PLPaymentType)paymentType
      completionHandler:(PLPaidCompletionHandler)handler;

@end
