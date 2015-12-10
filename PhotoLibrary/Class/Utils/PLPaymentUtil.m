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
    return programId != nil ? [payment containsObject:programId] : payment != nil;
}

+ (void)setPaymentStatus:(PLPaymentStatus *)status withProgram:(NSNumber *)programId forUsage:(PLPaymentUsage)usage {
    PLPaymentM *payment = [[self paymentWithUsage:usage status:status] mutableCopy];
    if (!payment) {
        payment = [PLPaymentM array];
    }
    
    if (programId) {
        [payment addObject:programId];
    }
    [self setPayment:payment withUsage:usage status:status];
}

+ (BOOL)isPaidForPayable:(id<PLPayable>)payable {
    if ([payable payableFee].unsignedIntegerValue == 0) {
        return YES;
    }
    
    if ([payable payableUsage] == PLPaymentForVideo) {
        return [self paymentWithUsage:PLPaymentForVideo status:kPaymentStatusPaid] != nil;
    } else {
        return [self isProgram:[payable contentId] forUsage:[payable payableUsage] withPaymentStatus:kPaymentStatusPaid];
    }
}

+ (void)setPaidForPayable:(id<PLPayable>)payable {
    if ([payable payableUsage] == PLPaymentForVideo) {
        PLPayment *payment = @[[payable payableFee]];
        [self setPayment:payment withUsage:[payable payableUsage] status:kPaymentStatusPaid];
    } else {
        [self setPaymentStatus:kPaymentStatusPaid withProgram:[payable contentId] forUsage:[payable payableUsage]];
    }
}

+ (void)setPaidPendingWithOrder:(NSArray *)order programId:(NSNumber *)programId forUsage:(PLPaymentUsage)usage {
    
}

@end
