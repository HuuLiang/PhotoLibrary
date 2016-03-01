//
//  PLPhotoChannelPopupMenuController.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPopupMenuController.h"

@class PLPhotoChannel;

typedef void (^PLPhotoChannelSelectAction)(PLPhotoChannel *selectedChannel, id sender);

@interface PLPhotoChannelPopupMenuController : PLPopupMenuController

@property (nonatomic,retain) PLPhotoChannel *selectedPhotoChannel;
@property (nonatomic,copy) PLPhotoChannelSelectAction photoChannelSelAction;

@end
