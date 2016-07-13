//
//  PLPaymentInfo.h
//  PhotoLibrary
//
//  Created by QubaCSC on 15/12/22.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PLPaymentStatusInfo) {
    PLPaymentStatusUnknown,
    PLPaymentStatusPaying,
    PLPaymentStatusNotProcessed,//没处理
    PLPaymentStatusProcessed//处理了
};

@interface PLPaymentInfo : NSObject

@property (nonatomic) NSString *paymentId;
@property (nonatomic) NSString *orderId;
@property (nonatomic) NSNumber *orderPrice;
@property (nonatomic) NSNumber *contentId;
@property (nonatomic) NSNumber *contentType;
@property (nonatomic) NSNumber *payPointType;
@property (nonatomic) NSString *paymentTime;
@property (nonatomic) NSNumber *paymentType;
@property (nonatomic) NSNumber *paymentResult;
@property (nonatomic) NSNumber *paymentStatus;
@property (nonatomic) NSString *reservedData;
// 商户信息
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;
/**返回支付信息*/
+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment;
- (void)save;
- (BOOL)isValid ;

@end
