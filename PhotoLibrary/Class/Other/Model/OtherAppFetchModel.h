//
//  OtherAppFetchModel.h
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "OtherApp.h"

typedef void(^PLFetchOtherAppCompletionHandler) (BOOL success,OtherApp*photo);

@interface OtherAppFetchModel : PLEncryptedURLRequest

@property (nonatomic,strong) OtherApp *freeFetchedPhoto;

/**根据当前页码获取数据*/
- (BOOL)fetchOtherAppWithPageNo:(NSInteger) pageNo completionHandler:(PLFetchOtherAppCompletionHandler)handler;

@end
