//
//  PLAlipayOrderQueryRequest.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLURLRequest.h"

@interface PLAlipayOrderQueryResponse : PLURLResponse

@property (nonatomic) NSString *trade_no;
@property (nonatomic) NSString *out_trade_no;

@end

typedef void (^PLAlipayOrderQueryCompletionHandler)(BOOL success, NSString *trade_status);

@interface PLAlipayOrderQueryRequest : PLURLRequest

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(PLAlipayOrderQueryCompletionHandler)handler;

@end
