//
//  PLSystemConfigModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLSystemConfig.h"

@interface PLSystemConfigResponse : PLURLResponse
@property (nonatomic,retain) NSArray<PLSystemConfig> *confis;
@end

typedef void (^PLFetchSystemConfigCompletionHandler)(BOOL success);

@interface PLSystemConfigModel : PLEncryptedURLRequest

@property (nonatomic) double payAmount;
@property (nonatomic) NSString *spreadTopImage;

+ (instancetype)sharedModel;

- (BOOL)fetchSystemConfigWithCompletionHandler:(PLFetchSystemConfigCompletionHandler)handler;

@end
