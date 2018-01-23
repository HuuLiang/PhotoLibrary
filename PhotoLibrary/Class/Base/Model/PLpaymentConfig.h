//
//  PLPaymentConfig.h
//  PhotoLibrary
//
//  Created by ZF on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLURLResponse.h"

typedef NS_ENUM(NSUInteger, KbIAppPayType) {
    PLIAppPayTypeUnknown = 0,
    PLIAppPayTypeWeChat = 1 << 0,
    PLIAppPayTypeAlipay = 1 << 1
};

@interface PLWeChatPaymentConfig : NSObject
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)defaultConfig;
@end

@interface PLAlipayConfig : NSObject

@property (nonatomic) NSString *partner;
@property (nonatomic) NSString *seller;
@property (nonatomic) NSString *productInfo;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)defaultConfig;
@end


@interface PLIAppPayConfig : NSObject
@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;
@property (nonatomic) NSNumber *supportPayTypes;

+ (instancetype)defaultConfig;
@end

@interface PLPaymentConfig : PLURLResponse

@property (nonatomic,retain) PLWeChatPaymentConfig *weixinInfo;
@property (nonatomic,retain) PLAlipayConfig *alipayInfo;
//@property (nonatomic,retain) PLIAppPayConfig *iappPayInfo;

@property (nonatomic) NSString *imgUrl;
@property (nonatomic) NSNumber *firstPayPages;
@property (nonatomic) NSString *vipPointInfo;
@property (nonatomic) NSString *ballPayWindowurl;
@property (nonatomic) NSString *payImgUrl;
@property (nonatomic) NSArray *userNames;

//+ (instancetype)sharedConfig;
+ (instancetype)configFromPersistence;
- (void)persist;
+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;


@end
