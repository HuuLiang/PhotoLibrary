//
//  PLFreePhoto.m
//  PhotoLibrary
//
//  Created by ZF on 16/2/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLFreePhoto.h"

@implementation PLFreePhoto

- (NSNumber *)payableFee {
#ifdef DEBUG
    return @1;
#else
    return self.payAmount1;
#endif
}

- (PLPaymentUsage)payableUsage {
//    return PLPaymentForVideo;
//    return PLPaymentForUnknown;
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
