//
//  PLProgramUrlModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLProgramUrlModel.h"

@implementation PLProgramUrlResponse

- (Class)programUrlListElementClass {
    return [PLProgramUrl class];
}

@end

@implementation PLProgramUrlModel

+ (Class)responseClass {
    return [PLProgramUrlResponse class];
}

- (BOOL)fetchUrlListWithProgramId:(NSNumber *)programId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(PLFetchUrlListCompletionHandler)handler {
    @weakify(self);
    
    NSDictionary *params = @{@"programId":programId, @"urlPage":@(pageNo), @"urlPageSize":@(pageSize)};
    BOOL ret = [self requestURLPath:[PLConfig sharedConfig].photoUrlListURLPath
                         withParams:params
                    responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        NSArray *urlList;
        if (respStatus == PLURLResponseSuccess) {
            PLProgramUrlResponse *resp = self.response;
            urlList = resp.programUrlList;
            self.fetchedUrlList = urlList;
        }
        
        if (handler) {
            handler(respStatus == PLURLResponseSuccess, urlList);
        }
    }];
    return ret;
}
@end
