//
//  PLEncryptedURLRequest.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/14.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLURLRequest.h"

@interface PLEncryptedURLRequest : PLURLRequest

+ (NSString *)signKey;
+ (NSDictionary *)commonParams;
+ (NSArray *)keyOrdersOfCommonParams;
- (NSDictionary *)encryptWithParams:(NSDictionary *)params;
/**解析AFN返回的数据*/
- (id)decryptResponse:(id)encryptedResponse;

@end