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
    PLPaymentStatusNotProcessed,
    PLPaymentStatusProcessed
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

+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment;
- (void)save;


@end
