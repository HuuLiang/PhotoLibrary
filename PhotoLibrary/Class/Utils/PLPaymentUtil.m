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

/**返回存储到本地的keyname*///—>4.
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

/**返回字典*///->3.
+ (PLPayments *)paymentsWithUsage:(PLPaymentUsage)usage {
    NSString *keyname = [self paymentKeyNameForUsage:usage];
    if (!keyname) {
        return nil;
    }
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyname];
}
#pragma mark - 返回查询本地数据的结果
/**返回数组*/
+ (PLPayment *)paymentWithUsage:(PLPaymentUsage)usage status:(PLPaymentStatus *)status {
    return [self paymentsWithUsage:usage][status];//支付状态作为一个key，取出字典的key对应的数组
}
#pragma mark - 保存支付信息
/**存储支付视频的信息*///->2.
+ (void)setPayment:(PLPayment *)payment withUsage:(PLPaymentUsage)usage status:(PLPaymentStatus *)status {//status作为内部的key，usage对应的值作为本地存储路径的key
    //可变字典
    PLPaymentsM *payments = [self paymentsWithUsage:usage].mutableCopy;//取出存入本地的字典，如果没有值说明，之前没有存储过
    if (!payments) {
        payments = [PLPaymentsM dictionary];//如果没有那就初始化一个字典，来存储
    }
    [payments setObject:payment forKey:status];//向字典中添加东西，status作为key，payment(数组)作为value
    
    [[NSUserDefaults standardUserDefaults] setObject:payments forKey:[self paymentKeyNameForUsage:usage]];//为不同的东西支付，存储到本地，对应不同的key......找到那个key向其中添加东西，覆盖掉原来的字典
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isProgram:(NSNumber *)programId forUsage:(PLPaymentUsage)usage withPaymentStatus:(PLPaymentStatus *)status {
    //数组
    PLPayment *payment = [self paymentWithUsage:usage status:status];//返回的数据
    return programId != nil ? [payment containsObject:programId] : payment != nil;
}

/**存储支付的是其他东西的信息*/
+ (void)setPaymentStatus:(PLPaymentStatus *)status withProgram:(NSNumber *)programId forUsage:(PLPaymentUsage)usage {
    //数组
    PLPaymentM *payment = [[self paymentWithUsage:usage status:status] mutableCopy];//先查询本地有没有存储过这个东西，有的话，说明已经支付过
    if (!payment) {//如果没有发现支付的东西，说明之前没有支付过就初始化一个数组
        payment = [PLPaymentM array];
    }
    
    if (programId) {
        [payment addObject:programId];//如果有值，加入数组
    }
    //保存支付信息
    [self setPayment:payment withUsage:usage status:status];
}

#pragma mark - 查询xxx是否支付了
/**是否支付成功*/
+ (BOOL)isPaidForPayable:(id<PLPayable>)payable {
    if ([payable payableFee].unsignedIntegerValue == 0) {
        return YES;
    }
    
    if ([payable payableUsage] == PLPaymentForVideo) {//支付的是Video
        return [self paymentWithUsage:PLPaymentForVideo status:kPaymentStatusPaid] != nil;//判断当前的数组中有没有值，有值的话就说明已经支付了
    } else {
        return [self isProgram:[payable contentId] forUsage:[payable payableUsage] withPaymentStatus:kPaymentStatusPaid];
    }
}
#pragma mark - 设置xxx已经支付
/**设置xxx已经支付*///->1.
+ (void)setPaidForPayable:(id<PLPayable>)payable {
    if ([payable payableUsage] == PLPaymentForVideo) {//支付的是视频
        PLPayment *payment = @[[payable payableFee]];//里面装的是支付金额
        [self setPayment:payment withUsage:[payable payableUsage] status:kPaymentStatusPaid];
    } else {//支付的是其他东西，有columnId的
        [self setPaymentStatus:kPaymentStatusPaid withProgram:[payable contentId] forUsage:[payable payableUsage]];//支付的是其他东西的话，就存储当前的conlumID，作为标示，
    }
}

+ (void)setPaidPendingWithOrder:(NSArray *)order programId:(NSNumber *)programId forUsage:(PLPaymentUsage)usage {
    
}

@end
