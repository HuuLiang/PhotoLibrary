//
//  PLChannelProgramModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLChannelProgram.h"

@interface PLChannelProgramResponse : PLChannelPrograms

@end

typedef void (^PLFetchChannelProgramCompletionHandler)(BOOL success, PLChannelPrograms *programs);

@interface PLChannelProgramModel : PLEncryptedURLRequest

@property (nonatomic,retain) PLChannelPrograms *fetchedPrograms;

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(PLFetchChannelProgramCompletionHandler)handler;

@end
