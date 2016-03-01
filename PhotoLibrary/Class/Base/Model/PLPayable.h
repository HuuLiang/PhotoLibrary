//
//  PLPayable.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#ifndef PLPayable_h
#define PLPayable_h

@protocol PLPayable <NSObject>

@required
- (NSNumber *)payableFee;
- (PLPaymentUsage)payableUsage;

@optional
- (NSNumber *)contentId;
- (NSNumber *)contentType;
- (NSNumber *)payPointType;

@end
#endif /* PLPayable_h */
