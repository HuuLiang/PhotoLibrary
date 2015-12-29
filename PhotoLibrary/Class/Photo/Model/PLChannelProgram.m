//
//  PLChannelProgram.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLChannelProgram.h"

@implementation PLChannelProgram

@end

@implementation PLChannelPrograms

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