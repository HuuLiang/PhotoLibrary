//
//  PLPaymentUtil.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPaymentUtil.h"

static NSString *const kPaymentForPhotoChannelUsageKeyName = @"photolib_payment_for_photo_channel_usage_keyname";
static NSString *const kPaymentForPhotoAlbumUsageKeyName = @"photolib_payment_for_photo_album_usage_keyname";
static NSString *const kPaymentForVideoUsageKeyName = @"photolib_payment_for_video_usage_keyname";

// Payment Status
static NSString *const kPaymentStatusNotPaid = @"photolib_payment_status_not_paid";
static NSString *const kPaymentStatusInPaying = @"photolib_payment_status_in_paying";
static NSString *const kPaymentStatusPaidPending = @"photolib_payment_status_paid_pending";
static NSString *const kPaymentStatusPaid = @"photolib_payment_status_paid";

typedef NSArray PLPayment;
typedef NSMutableArray PLPaymentM;
typedef NSDictionary<NSString *, PLPayment *> PLPayments;
typedef NSMutableDictionary PLPaymentsM;
typedef NSString PLPaymentStatus;

@interface PLPaymentUtil ()

+ (id)paymentWithUsage:(PLPaymentUsage)usage status:(PLPaymentStatus *)status;
@end

@implementation PLPaymentUtil

+ (NSString *)paymentKeyNameForUsage:(PLPaymentUsage)usage {
    NSString *keyname;
    switch (usage) {
        case PLPaymentForPhotoChannel:
            keyname = kPaymentForPhotoChannelUsageKeyName;
            break;
        case PLPaymentForPhotoAlbum:
            keyname = kPaymentForPhotoAlbumUsageKeyName;
            break;
        case PLPaymentForVideo:
            keyname = kPaymentForVideoUsageKeyName;
            break;
        default:
            break;
    }
    return keyname;
}

+ (PLPayments *)paymentsWithUsage:(PLPaymentUsage)usage {
    NSString *keyname = [self paymentKeyNameForUsage:usage];
    if (!keyname) {
        return nil;
    }
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyname];
}

+ (PLPayment *)paymentWithUsage:(PLPaymentUsage)usage status:(PLPaymentStatus *)status {
    return [self paymentsWithUsage:usage][status];
}

+ (void)setPayment:(PLPayment *)payment withUsage:(PLPaymentUsage)usage status:(PLPaymentStatus *)status {
    PLPaymentsM *payments = [self paymentsWithUsage:usage].mutableCopy;
    if (!payments) {
        payments = [PLPaymentsM dictionary];
    }
    [payments setObject:payment forKey:status];
    [[NSUserDefaults standardUserDefaults] setObject:payments forKey:[self paymentKeyNameForUsage:usage]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isProgram:(NSNumber *)programId forUsage:(PLPaymentUsage)usage withPaymentStatus:(PLPaymentStatus *)status {
    PLPayment *payment = [self paymentWithUsage:usage status:status];
    return [payment containsObject:programId];
}

+ (void)setPaymentStatus:(PLPaymentStatus *)status withProgram:(NSNumber *)programId forUsage:(PLPaymentUsage)usage {
    PLPaymentM *payment = [[self paymentWithUsage:usage status:status] mutableCopy];
    if (!payment) {
        payment = [PLPaymentM array];
    }
    
    [payment addObject:programId];
    [self setPayment:payment withUsage:usage status:status];
}

+ (BOOL)isPaidForUsage:(PLPaymentUsage)usage withProgramId:(NSNumber *)programId {
    return [self isProgram:programId forUsage:usage withPaymentStatus:kPaymentStatusPaid];
}

+ (void)setPaidForUsage:(PLPaymentUsage)usage withProgramId:(NSNumber *)programId {
    [self setPaymentStatus:kPaymentStatusPaid withProgram:programId forUsage:usage];
}

+ (void)setPaidPendingWithOrder:(NSArray *)order programId:(NSNumber *)programId forUsage:(PLPaymentUsage)usage {
    
}

+ (void)setPayingOrder:(NSDictionary<NSString *, id> *)orderInfo forUsage:(PLPaymentUsage)usage withProgramId:(NSNumber *)programId {
    
}

+ (NSDictionary<NSString *, id> *)payingOrderForUsage:(PLPaymentUsage)usage withProgramId:(NSNumber *)programId {
    return nil;
}

@end
