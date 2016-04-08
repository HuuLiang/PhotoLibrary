//
//  PLVideoModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/6.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLVideoModel.h"

@implementation PLVideoModel

+ (Class)responseClass {
    return [PLVideos class];
}

- (BOOL)fetchVideosWithPageNo:(NSUInteger)pageNo
            completionHandler:(PLFetchVideosCompletionHandler)handler
{
    @weakify(self);
    BOOL ret = [self requestURLPath:PL_VIDEO_URL
                         withParams:@{@"page":@(pageNo)}
                    responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        PLVideos *videos;
        if (respStatus == PLURLResponseSuccess) {
            videos = self.response;
            self.fetchedVideos = videos;
        }
        
        if (handler) {
            handler(respStatus == PLURLResponseSuccess, videos);
        }
    }];
    return ret;
}

@end
