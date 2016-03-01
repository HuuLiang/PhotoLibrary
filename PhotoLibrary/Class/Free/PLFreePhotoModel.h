//
//  PLFreePhotoModel.h
//  PhotoLibrary
//
//  Created by ZF on 16/2/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"

#import "PLFreePhoto.h"


/**定义一个block类型*/
typedef void(^PLFetchFreePhotosCompletionHandler) (BOOL success,PLFreePhoto*photo);

@interface PLFreePhotoModel : PLEncryptedURLRequest

@property (nonatomic,strong) PLFreePhoto *freeFetchedPhoto;

/**根据当前页码获取数据*/
- (BOOL)fetchFreePhotosWithPageNo:(NSInteger) pageNo completionHandler:(PLFetchFreePhotosCompletionHandler)handler;
@end
