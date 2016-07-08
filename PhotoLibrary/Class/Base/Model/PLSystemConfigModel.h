//
//  PLSystemConfigModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLSystemConfig.h"

//.........一个继承于PLURLResponse的类
@interface PLSystemConfigResponse : PLURLResponse
@property (nonatomic,retain) NSArray<PLSystemConfig> *confis;
@end

//.........获取系统数据的模型
typedef void (^PLFetchSystemConfigCompletionHandler)(BOOL success);

@interface PLSystemConfigModel : PLEncryptedURLRequest

@property (nonatomic) NSString *isApplePay;
@property (nonatomic) NSInteger photoPrice;
@property (nonatomic) NSInteger videoPrice;
@property (nonatomic) NSString *channelPopImgUrl;
@property (nonatomic) NSString *ChannelBannerImgUrl;

+ (instancetype)sharedModel;

/**获取系统数据*/
- (BOOL)fetchSystemConfigWithCompletionHandler:(PLFetchSystemConfigCompletionHandler)handler;

@end
