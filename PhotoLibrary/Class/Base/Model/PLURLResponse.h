//
//  PLURLResponse.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLURLResponse : NSObject

@property (nonatomic) NSNumber *success;
@property (nonatomic) NSString *resultCode;

/**解析字典，转模型*/
- (void)parseResponseWithDictionary:(NSDictionary *)dic;

@end
