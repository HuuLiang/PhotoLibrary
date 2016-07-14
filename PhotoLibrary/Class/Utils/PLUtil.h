//
//  PLUtil.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPaymentInfo.h"

typedef NS_ENUM(NSUInteger, PLPendingOrderItem) {
    PLPendingOrderId,
    PLPendingOrderPrice,
    PLPendingOrderProgramId,
    PLPendingOrderProgramType,
    PLPendingOrderPayPointType,
    PLPendingOrderPaymentType,
    PLPendingOrderItemCount
};

@interface PLUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

+ (NSArray<PLPaymentInfo *> *)payingPaymentInfos;
+ (NSArray<PLPaymentInfo *> *)paidNotProcessedPaymentInfos;
+ (BOOL)isPaid;

+ (NSString *)accessId;
+ (NSString *)userId;
+ (NSString *)deviceName;
+ (NSUInteger)appVersion;
+ (void)checkAppInstalledWithBundleId:(NSString *)bundleId completionHandler:(void (^)(BOOL))handler;

+ (BOOL)isApplePay;//是否是苹果内购
+ (BOOL) isAppleStore;//是否需要切换素版bannner和支付图片
// For test only
+ (void)removeKeyChainEntries;

+ (NSString *)currentDateString;

@end
