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

- (BOOL)fetchUrlListWithProgramId:(NSNumber *)programId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(PLFetchUrlListCompletionHandler)handler;

@end
