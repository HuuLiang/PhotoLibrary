//
//  PLUtil.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLUtil.h"
#import <SFHFKeychainUtils.h>
#import <sys/sysctl.h>
#import "YYKApplicationManager.h"
#import "PLSystemConfigModel.h"
//#define USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT

#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT

static NSString *const kRegisterKeyChainUsername = @"photolib_register_username";
static NSString *const kRegisterKeyChainServiceName = @"photolib_register_servicename";
//static NSString *const kRegisterPendingKeyChainPassword = @"photolib_register_pending";

static NSString *const kPaidKeyChainUsername = @"photolib_paid_username";
static NSString *const kPaidKeyChainServiceName = @"photolib_paid_servicename";
//static NSString *const kPaidKeyChainPassword = @"photolib_paid_password";

#else
static NSString *const kRegisterKeyName = @"photolib_register_keyname";
static NSString *const kPaidKeyName = @"photolib_paid_keyname";
static NSString *const kPayingOrderKeyName = @"photolib_paying_order_keyname";
#endif

static NSString *const kUserAccessUsername = @"photolib_user_access_username";
static NSString *const kUserAccessServicename = @"photolib_user_access_service";

static NSString *const kPhotoChannelPaymentKeyName = @"photolib_photo_channel_payment_keyname";

static NSString *const kPaymentForPhotoChannelUsageKeyName = @"photolib_payment_for_photo_channel_usage_keyname";
static NSString *const kPaymentForPhotoAlbumUsageKeyName = @"photolib_payment_for_photo_album_usage_keyname";
static NSString *const kPaymentForVideoUsageKeyName = @"photolib_payment_for_video_usage_keyname";

@implementation PLUtil

+ (void)setPaidForPhotoChannel:(NSNumber *)columnId {
    NSArray *payment = [[NSUserDefaults standardUserDefaults] objectForKey:kPhotoChannelPaymentKeyName];
    
    NSMutableArray *paymentM = payment.mutableCopy;
    if (!paymentM) {
        paymentM = [NSMutableArray array];
    }
    
    [paymentM addObject:columnId];
    [[NSUserDefaults standardUserDefaults] setObject:paymentM forKey:kPhotoChannelPaymentKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isPaidForPhotoChannel:(NSNumber *)columnId {
    NSArray *payment = [[NSUserDefaults standardUserDefaults] objectForKey:kPhotoChannelPaymentKeyName];
    return [payment containsObject:columnId];
}

+ (void)removeKeyChainEntries {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils deleteItemForUsername:kRegisterKeyChainUsername.md5
                              andServiceName:kRegisterKeyChainServiceName.md5
                                       error:nil];
    
    [SFHFKeychainUtils deleteItemForUsername:kPaidKeyChainUsername.md5
                              andServiceName:kPaidKeyChainServiceName.md5
                                       error:nil];
#else
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPaidKeyName];
    
#endif
    
    [SFHFKeychainUtils deleteItemForUsername:kUserAccessUsername andServiceName:kUserAccessServicename error:nil];
}

+ (NSString *)accessId {
    NSString *accessIdInKeyChain = [SFHFKeychainUtils getPasswordForUsername:kUserAccessUsername andServiceName:kUserAccessServicename error:nil];
    if (accessIdInKeyChain) {
        return accessIdInKeyChain;
    }
    
    accessIdInKeyChain = [NSUUID UUID].UUIDString.md5;
    [SFHFKeychainUtils storeUsername:kUserAccessUsername andPassword:accessIdInKeyChain forServiceName:kUserAccessServicename updateExisting:YES error:nil];
    return accessIdInKeyChain;
}

+ (NSArray<PLPaymentInfo *> *)allPaymentInfos {
    NSArray<NSDictionary *> *paymentInfoArr = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfos = [NSMutableArray array];
    [paymentInfoArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PLPaymentInfo *paymentInfo = [PLPaymentInfo paymentInfoFromDictionary:obj];
        [paymentInfos addObject:paymentInfo];
    }];
    return paymentInfos;
}

+(BOOL)PLisPaid{
    return [self.allPaymentInfos bk_any:^BOOL(id obj) {
        PLPaymentInfo *paymentInfo = obj;
        if (paymentInfo.paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
            return YES;
        }
        return NO;
    }];
}

+ (NSArray<PLPaymentInfo *> *)payingPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        PLPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == PLPaymentStatusPaying;
    }];
}
/**是否注册*/
+ (BOOL)isRegistered {
    return [self userId] != nil;
}
/**注册*/
+ (void)setRegisteredWithUserId:(NSString *)userId {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils storeUsername:kRegisterKeyChainUsername.md5
                         andPassword:userId
                      forServiceName:kRegisterKeyChainServiceName.md5
                      updateExisting:YES
                               error:nil];
#else
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

+ (NSArray<PLPaymentInfo *> *)paidNotProcessedPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        PLPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == PLPaymentStatusNotProcessed;
    }];
}

+ (BOOL)isPaid {
    return [self orderInKeyChain] != nil;
}

+ (void)setPaid {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils storeUsername:kPaidKeyChainUsername.md5
                         andPassword:[NSString stringWithFormat:@"%@|%@", [self userId], [self orderInKeyChain]]
                      forServiceName:kPaidKeyChainServiceName.md5
                      updateExisting:YES
                               error:nil];
#else
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@|%@", [self userId], [self orderInKeyChain]]
                                              forKey:kPaidKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

+ (void)setPaidPendingWithOrder:(NSArray *)order; {
    NSMutableString *orderString = [NSMutableString string];
    [order enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [orderString appendString:obj];
        
        if (idx != order.count - 1) {
            [orderString appendString:@"&"];
        }
    }];
    
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils storeUsername:kPaidKeyChainUsername.md5
                         andPassword:orderString
                      forServiceName:kPaidKeyChainServiceName.md5
                      updateExisting:YES
                               error:nil];
#else
    [[NSUserDefaults standardUserDefaults] setObject:orderString forKey:kPaidKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

+ (void)setPayingOrder:(NSDictionary<NSString *, id> *)orderInfo {
    [[NSUserDefaults standardUserDefaults] setObject:orderInfo forKey:kPayingOrderKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary<NSString *, id> *)payingOrder {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPayingOrderKeyName];
}

+ (NSString *)payingOrderNo {
    return [self payingOrder][@(PLPendingOrderId).stringValue];
}

+ (PLPaymentType)payingOrderPaymentType {
    return ((NSNumber *)[self payingOrder][@(PLPendingOrderPaymentType).stringValue]).unsignedIntegerValue;
}

+ (void)setPayingOrderWithOrderNo:(NSString *)orderNo paymentType:(PLPaymentType)paymentType {
    NSDictionary *payingOrder = @{@(PLPendingOrderId).stringValue:orderNo,
                                  @(PLPendingOrderPaymentType).stringValue:@(paymentType)};
    [self setPayingOrder:payingOrder];
}

+ (NSString *)userIdInPayment {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    NSString *payment = [SFHFKeychainUtils getPasswordForUsername:kPaidKeyChainUsername.md5
                                                   andServiceName:kPaidKeyChainServiceName.md5
                                                            error:nil];
#else
    NSString *payment = [[NSUserDefaults standardUserDefaults] objectForKey:kPaidKeyName];
#endif
    NSArray *separatedStrings = [payment componentsSeparatedByString:@"|"];
    if (separatedStrings.count != 2) {
        return nil;
    }
    return separatedStrings[0];
}

+ (NSString *)orderInKeyChain {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    NSString *payment = [SFHFKeychainUtils getPasswordForUsername:kPaidKeyChainUsername.md5
                                                   andServiceName:kPaidKeyChainServiceName.md5
                                                            error:nil];
#else
    NSString *payment = [[NSUserDefaults standardUserDefaults] objectForKey:kPaidKeyName];
#endif
    NSArray *separatedStrings = [payment componentsSeparatedByString:@"|"];
    return separatedStrings.lastObject;
}

+ (NSString *)userId {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    return [SFHFKeychainUtils getPasswordForUsername:kRegisterKeyChainUsername.md5
                                      andServiceName:kRegisterKeyChainServiceName.md5
                                               error:nil];
#else
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRegisterKeyName];
#endif
}

+ (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}
/**app版本*/
+ (NSUInteger)appVersion {
    NSString *ver = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    return ver.floatValue * 100;
}

+ (void)checkAppInstalledWithBundleId:(NSString *)bundleId completionHandler:(void (^)(BOOL))handler {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL installed = [[[YYKApplicationManager defaultManager] allInstalledAppIdentifiers] bk_any:^BOOL(id obj) {
            return [bundleId isEqualToString:obj];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(installed);
            }
        });
    });
}
+ (NSString *)currentDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDefaultDateFormat];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (BOOL)isApplePay {
    if ([[PLSystemConfigModel sharedModel].isApplePay isEqualToString:@"YES"]) {
        return YES;
    }else {
        return NO;
    }
}

+ (BOOL) isAppleStore {
    if ([[PLSystemConfigModel sharedModel].isAppleStore isEqualToString:@"YES"]) {
        return YES;
    }
    return NO;
}

@end
