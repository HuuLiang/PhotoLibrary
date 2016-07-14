//
//  PLApplePay.h
//  PhotoLibrary
//
//  Created by ylz on 16/7/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface PLApplePay : NSObject

@property (nonatomic) BOOL isGettingPriceInfo;


+ (instancetype)shareApplePay;

- (void)getProdructionInfo;
- (void)payWithProductionId:(NSString *)proId;

@end
