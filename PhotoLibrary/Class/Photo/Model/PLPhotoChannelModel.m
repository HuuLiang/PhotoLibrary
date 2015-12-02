//
//  PLPhotoChannelModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoChannelModel.h"

@implementation PLPhotoChannelResponse

- (Class)columnListElementClass {
    return [PLPhotoChannel class];
}

@end

@implementation PLPhotoChannelModel

+ (Class)responseClass {
    return [PLPhotoChannelResponse class];
}

- (BOOL)fetchPhotoChannelsWithCompletionHandler:(PLFetchPhotoChannelsCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:[PLConfig sharedConfig].photoChannelURLPath withParams:nil responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage) {
        @strongify(self);
        if (respStatus == PLURLResponseSuccess) {
            PLPhotoChannelResponse *channelResp = self.response;
            self->_fetchedChannels = channelResp.columnList;
            
            if (handler) {
                handler(YES, self->_fetchedChannels);
            }
        } else {
            if (handler) {
                handler(NO, nil);
            }
        }
    }];
    return ret;
}
@end
