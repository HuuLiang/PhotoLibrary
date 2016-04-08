//
//  PLChannelProgramModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLChannelProgramModel.h"

@implementation PLChannelProgramResponse

@end

@implementation PLChannelProgramModel

+ (Class)responseClass {
    return [PLChannelProgramResponse class];
}

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(PLFetchChannelProgramCompletionHandler)handler {
    @weakify(self);
    NSDictionary *params = @{@"columnId":columnId, @"page":@(pageNo), @"pageSize":@(pageSize)};
    BOOL success = [self requestURLPath:PL_PHOTO_CHANNEL_PROGRAM_URL
                             withParams:params
                        responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        @strongify(self);
                        
                        PLChannelPrograms *programs;
                        if (respStatus == PLURLResponseSuccess) {
                            programs = (PLChannelProgramResponse *)self.response;
                            self.fetchedPrograms = programs;//在这里保存到自己的全局变量，共外界调用
                        }
                        
                        if (handler) {
                            handler(respStatus==PLURLResponseSuccess, programs);
                        }
                    }];
    return success;
}
@end
