//
//  PLPaymentUtil.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PLPaymentUsage) {
    PLPaymentForUnknown,
    PLPaymentForPhotoChannel,
    PLPaymentForPhotoAlbum,
    PLPaymentForVideo
};

@interface PLPaymentUtil : NSObject

+ (BOOL)isPaidForUsage:(PLPaymentUsage)usage withProgramId:(NSNumber *)programId;
+ (void)setPaidForUsage:(PLPaymentUsage)usage  withProgramId:(NSNumber *)programId;
+ (void)setPaidPendingWithOrder:(NSArray *)order programId:(NSNumber *)programId forUsage:(PLPaymentUsage)usage;

+ (void)setPayingOrder:(NSDictionary<NSString *, id> *)orderInfo forUsage:(PLPaymentUsage)usage withProgramId:(NSNumber *)programId;
+ (NSDictionary<NSString *, id> *)payingOrderForUsage:(PLPaymentUsage)usage withProgramId:(NSNumber *)programId;

@end
