//
//  PLProgramUrlModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLProgram.h"

@interface PLProgramUrlResponse : PLURLResponse
@property (nonatomic) NSArray<PLProgramUrl *> *programUrlList;
@end

typedef void (^PLFetchUrlListCompletionHandler)(BOOL success, NSArray<PLProgramUrl *> *urlList);

@interface PLProgramUrlModel : PLEncryptedURLRequest

@property (nonatomic,retain) NSArray<PLProgramUrl *> *fetchedUrlList;
/**根据要获取的图片的programId，以及图片的page，pageSize来获取当前路径的所有的图片，返回的图片路径在两个地方，一个时装在了self.fetchedUrlList中，一个在block的返回值中*/
- (BOOL)fetchUrlListWithProgramId:(NSNumber *)programId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(PLFetchUrlListCompletionHandler)handler;

@end
