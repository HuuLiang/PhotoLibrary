//
//  OtherAppFetchModel.m
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "OtherAppFetchModel.h"
#import "OtherApp.h"
@implementation OtherAppFetchModel

+ (Class)responseClass {
    return [OtherApp class];
}

- (BOOL)fetchOtherAppWithPageNo:(NSInteger) pageNo completionHandler:(PLFetchOtherAppCompletionHandler)handler{
    @weakify(self);
    BOOL ret = [self requestURLPath:PL_FREE_PHOTO_URL
                         withParams:@{@"page":@(pageNo)}
                    responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
                {
                    @strongify(self);
                    
                    OtherApp *photo;//返回的是一个栏目模型，里面有一个是数组
                    
                    if (respStatus == PLURLResponseSuccess) {
                        photo = self.response;
                        self.freeFetchedPhoto = photo;
                    }
                    
                    if (handler) {//激活代码块
                        handler(respStatus == PLURLResponseSuccess, photo);
                    }
                }];
    
    
    return ret;
    
}

@end
