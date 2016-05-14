//
//  OtherApp.m
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "OtherApp.h"

@implementation OtherApp
- (NSNumber *)payableFee {
#ifdef DEBUG
    return @1;
#else
    return self.payAmount1;
#endif
}

- (PLPaymentUsage)payableUsage {
    return PLPaymentForPhotoAlbum;
}

- (NSNumber *)contentId {
    return self.columnId;
}

- (NSNumber *)contentType {
    return self.type;
}

- (NSNumber *)payPointType {
    return nil;
}
@end
