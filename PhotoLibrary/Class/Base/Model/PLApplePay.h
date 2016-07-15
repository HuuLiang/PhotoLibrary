//
//  PLApplePay.h
//  PhotoLibrary
//
//  Created by ylz on 16/7/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void(^PLApplePayBackBlock)(SKPaymentTransactionState paystates);

@interface PLApplePay : NSObject

@property (nonatomic) BOOL isGettingPriceInfo;
@property (nonatomic,copy)PLApplePayBackBlock appPayBack;

+ (instancetype)shareApplePay;

- (void)getProdructionInfo;
- (void)payWithProductionId:(NSString *)proId;

@end
