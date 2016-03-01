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
/**各种需要的路径*/
@property (nonatomic,readonly) NSString *baseURL;
@property (nonatomic,readonly) NSString *photoChannelURLPath;
@property (nonatomic,readonly) NSString *photoChannelProgramURLPath;
@property (nonatomic,readonly) NSString *photoUrlListURLPath;
@property (nonatomic,readonly) NSString *videoURLPath;
@property (nonatomic,readonly) NSString *registerURLPath;
@property (nonatomic,readonly) NSString *systemConfigURLPath;
@property (nonatomic,readonly) NSString *userAccessURLPath;
@property (nonatomic,readonly) NSString *agreementURLPath;

@property (nonatomic,readonly) NSString *systemConfigPayAmount;
@property (nonatomic,readonly) NSString *systemConfigSpreadTopImage;

/**支付相关*/
@property (nonatomic,readonly) NSString *paymentURLPath;
@property (nonatomic,readonly) NSString *payNowScheme;
@property (nonatomic,readonly) NSString *paymentSignURLPath;

/**微信相关*/
@property (nonatomic,readonly) NSString *weChatPayAppId;
@property (nonatomic,readonly) NSString *weChatPayMchId;
@property (nonatomic,readonly) NSString *weChatPayPrivateKey;
@property (nonatomic,readonly) NSString *weChatPayNotifyURL;

/**百度相关*/
@property (nonatomic,readonly) NSString *baiduAdAppId;
@property (nonatomic,readonly) NSString *baiduBannerAdId;

@property (nonatomic,readonly) NSString *umengAppId;

@property (nonatomic,readonly) NSString *paymentReservedData;

/**单例创建对象，同时获取对应的所有属性*/
+ (instancetype)sharedConfig;

+ (instancetype)sharedStandbyConfig;
/**获取文件的接口.1*/
+ (instancetype)configWithName:(NSString *)configName;

@end
