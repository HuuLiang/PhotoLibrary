//
//  PLPaymentSignModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/8.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "PLEncryptedURLRequest.h"

@class IPNPreSignMessageUtil;

typedef void (^PLPaymentSignCompletionHandler)(BOOL success, NSString *signedData);

@interface PLPaymentSignModel : PLEncryptedURLRequest

@property (nonatomic,retain,readonly) NSString *appId;
@property (nonatomic,retain,readonly) NSString *notifyUrl;
@property (nonatomic,retain,readonly) NSString *signature;

+ (instancetype)sharedModel;

- (BOOL)signWithPreSignMessage:(IPNPreSignMessageUtil *)preSign completionHandler:(PLPaymentSignCompletionHandler)handler;

@end
