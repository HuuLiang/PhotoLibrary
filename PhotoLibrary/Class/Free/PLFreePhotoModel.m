//
//  PLFreePhotoModel.m
//  PhotoLibrary
//
//  Created by ZF on 16/2/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLFreePhotoModel.h"

@implementation PLFreePhotoModel

+ (Class)responseClass {
    return [PLFreePhoto class];
}
- (BOOL)fetchFreePhotosWithPageNo:(NSInteger)pageNo completionHandler:(PLFetchFreePhotosCompletionHandler)handler{
    @weakify(self);
    BOOL ret = [self requestURLPath:[PLConfig sharedConfig].freePhotoURLPath
                         withParams:@{@"page":@(pageNo)}
                    responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
                {
                    @strongify(self);
                    
                    PLFreePhoto *photo;//返回的是一个栏目模型，里面有一个是数组
                    
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
