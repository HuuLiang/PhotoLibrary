//
//  PLUtil.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

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

//+ (BOOL)isPaid;
//+ (void)setPaid;
//+ (void)setPaidPendingWithOrder:(NSArray *)order;
//
//+ (void)setPayingOrder:(NSDictionary<NSString *, id> *)orderInfo;
//+ (NSDictionary<NSString *, id> *)payingOrder;
//
//+ (void)setPaidForPhotoChannel:(NSNumber *)columnId;
//+ (BOOL)isPaidForPhotoChannel:(NSNumber *)columnId;
//
//// Methods for convenience
//+ (NSString *)payingOrderNo;
//+ (PLPaymentType)payingOrderPaymentType;
//+ (void)setPayingOrderWithOrderNo:(NSString *)orderNo paymentType:(PLPaymentType)paymentType;

+ (NSString *)accessId;

+ (NSArray *)orderForSavePending; // For last time not saved successfully to remote

+ (NSString *)userId;
+ (NSString *)deviceName;
+ (NSString *)appVersion;
+ (NSString *)appId;

// For test only
+ (void)removeKeyChainEntries;

@end
