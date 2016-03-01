//
//  PLVideoModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/6.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLVideo.h"

typedef void (^PLFetchVideosCompletionHandler)(BOOL success, PLVideos *videos);

@interface PLVideoModel : PLEncryptedURLRequest

@property (nonatomic,retain) PLVideos *fetchedVideos;

- (BOOL)fetchVideosWithPageNo:(NSUInteger)pageNo
            completionHandler:(PLFetchVideosCompletionHandler)handler;

@end
