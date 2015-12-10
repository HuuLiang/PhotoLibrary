//
//  PLConfig.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLConfig : NSObject

@property (nonatomic,readonly) NSString *channelNo;

@property (nonatomic,readonly) NSString *baseURL;
@property (nonatomic,readonly) NSString *photoChannelURLPath;
@property (nonatomic,readonly) NSString *photoChannelProgramURLPath;
@property (nonatomic,readonly) NSString *photoUrlListURLPath;
@property (nonatomic,readonly) NSString *videoURLPath;
@property (nonatomic,readonly) NSString *registerURLPath;
@property (nonatomic,readonly) NSString *systemConfigURLPath;
@property (nonatomic,readonly) NSString *userAccessURLPath;
@property (nonatomic,readonly) NSString *alipayConfigURLPath;
@property (nonatomic,readonly) NSString *weChatPayConfigURLPath;
@property (nonatomic,readonly) NSString *agreementURLPath;

@property (nonatomic,readonly) NSString *alipayPID;
@property (nonatomic,readonly) NSString *alipaySellerID;
@property (nonatomic,readonly) NSString *alipayScheme;
@property (nonatomic,readonly) NSString *alipayPrivateKey;
@property (nonatomic,readonly) NSString *alipayNotifyURL;

@property (nonatomic,readonly) NSString *weChatPayAppId;
@property (nonatomic,readonly) NSString *weChatPayMchId;
@property (nonatomic,readonly) NSString *weChatPayPrivateKey;
@property (nonatomic,readonly) NSString *weChatPayNotifyURL;

@property (nonatomic,readonly) NSString *systemConfigPayAmount;
@property (nonatomic,readonly) NSString *systemConfigSpreadTopImage;

@property (nonatomic,readonly) NSString *paymentURLPath;

//@property (nonatomic,readonly) NSString *baiduAdAppId;
//@property (nonatomic,readonly) NSString *baiduBannerAdId;
//@property (nonatomic,readonly) NSString *baiduLaunchAdId;
//
//@property (nonatomic,readonly) NSString *umengAppId;
//@property (nonatomic,readonly) NSString *umengTriggerPaymentEventId;
//@property (nonatomic,readonly) NSString *umengSuccessfulPaymentEventId;
//@property (nonatomic,readonly) NSString *umengFailedPaymentEventId;
//@property (nonatomic,readonly) NSString *umengCancelledPaymentEventId;

+ (instancetype)sharedConfig;
+ (instancetype)sharedStandbyConfig;
+ (instancetype)configWithName:(NSString *)configName;

@end
