//
//  PLCommonDef.h
//  PhotoLibrary
//
//  Created by Sean Yue on 16/4/8.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#ifndef PLCommonDef_h
#define PLCommonDef_h

typedef NS_ENUM(NSUInteger, PLPaymentType) {
    PLPaymentTypeNone,
    PLPaymentTypeAlipay = 1001,
    PLPaymentTypeWeChatPay = 1008,
    PLPaymentTypeIAppPay = 1009
};

typedef NS_ENUM(NSInteger, PAYRESULT)
{
    PAYRESULT_SUCCESS   = 0,
    PAYRESULT_FAIL      = 1,
    PAYRESULT_ABANDON   = 2,
    PAYRESULT_UNKNOWN   = 3
};

typedef NS_ENUM(NSUInteger, PLPaymentUsage) {
    PLPaymentForUnknown,
    PLPaymentForPhotoChannel,
    PLPaymentForPhotoAlbum,
    PLPaymentForVideo
};

typedef NS_ENUM(NSUInteger, PLChannelCategory) {
    PLPhotoChannelCategory,
    PLVideoChannelCategory
};

// DLog
#ifdef  DEBUG
#define DLog(fmt,...) {NSLog((@"%s [Line:%d]" fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);}
#else
#define DLog(...)
#endif

#define DefineLazyPropertyInitialization(propertyType, propertyName) \
-(propertyType *)propertyName { \
if (_##propertyName) { \
return _##propertyName; \
} \
_##propertyName = [[propertyType alloc] init]; \
return _##propertyName; \
}

#define kPaymentNotificationName  @"photolib_payment_notification"

//#define kPaidNotificationName @"photolib_paid_notification"
#define kPaymentNotificationOrderNoKey @"photolib_payment_notification_order_key"
#define kPaymentNotificationPriceKey @"photolib_payment_notification_price_key"
#define kPaymentNotificationPaymentType @"photolib_payment_notification_payment_type"

#define kPaymentInfoKeyName @"PL_paymentinfo_keyname"


#define kPhotoChannelIdKeyName @"PhotoChannelIdKeyName"
#define kDefaultPageSize  20

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kAutoPopupPaymentInScrollingPage (2)

//－－－－－－－－－－－－－－－－－－－－－－－
#define EnableBaiduMobBannerAd
#ifdef EnableBaiduMobBannerAd
#import "BaiduMobAdView.h"
#else
@protocol BaiduMobAdViewDelegate <NSObject>
@end
typedef UIView BaiduMobAdView;
#endif

#define SafelyCallBlock(block) if (block) block();
#define SafelyCallBlock1(block, arg) if (block) block(arg);
#define SafelyCallBlock2(block, arg1, arg2) if (block) block(arg1, arg2);
#define SafelyCallBlock3(block, arg1, arg2, arg3) if (block) block(arg1, arg2, arg3);


typedef void (^PLCompletionHandler)(BOOL success, id obj);
typedef void (^PLAction)(id obj);
#endif /* PLCommonDef_h */
