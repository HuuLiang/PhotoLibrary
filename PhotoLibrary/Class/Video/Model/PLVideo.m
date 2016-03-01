//
//  PLVideo.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLVideo.h"

@implementation PLVideo

@end

@implementation PLVideos

- (NSNumber *)payableFee {
#ifdef DEBUG
    return @1;
#else
    return self.payAmount;
#endif
}

- (PLPaymentUsage)payableUsage {
    return PLPaymentForVideo;
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