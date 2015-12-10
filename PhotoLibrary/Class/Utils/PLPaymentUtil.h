//
//  PLPaymentUtil.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPayable.h"

@interface PLPaymentUtil : NSObject

+ (BOOL)isPaidForPayable:(id<PLPayable>)payable;
+ (void)setPaidForPayable:(id<PLPayable>)payable;

+ (void)setPaidPendingWithOrder:(NSArray *)order programId:(NSNumber *)programId forUsage:(PLPaymentUsage)usage;

@end
