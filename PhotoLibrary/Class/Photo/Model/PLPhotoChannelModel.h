//
//  PLPhotoChannelModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"
#import "PLPhotoChannel.h"

@interface PLPhotoChannelResponse : PLURLResponse
@property (nonatomic,retain) NSMutableArray<PLPhotoChannel *> *columnList;
@end

typedef void (^PLFetchPhotoChannelsCompletionHandler)(BOOL success,
                                                      NSArray<PLPhotoChannel *> *channels);

@interface PLPhotoChannelModel : PLEncryptedURLRequest

@property (nonatomic,retain) NSArray<PLPhotoChannel *> *fetchedChannels;

- (BOOL)fetchPhotoChannelsWithCompletionHandler:(PLFetchPhotoChannelsCompletionHandler)handler;

@end
