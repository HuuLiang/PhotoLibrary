//
//  PLProgram.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLURLResponse.h"
#import "PLPayable.h"

typedef NS_ENUM(NSUInteger, PLProgramType) {
    PLProgramTypeNone = 0,
    PLProgramTypeVideo = 1,
    PLProgramTypePicture = 2
};

@protocol PLProgramUrl <NSObject>

@end

@interface PLProgramUrl : NSObject
@property (nonatomic) NSNumber *programUrlId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *url;
@property (nonatomic) NSNumber *width;
@property (nonatomic) NSNumber *height;
@end

@protocol PLProgram <NSObject>

@end

@interface PLProgram : NSObject

@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *specialDesc;
@property (nonatomic) NSString *videoUrl;
@property (nonatomic) NSString *coverImg;
@property (nonatomic) BOOL isHot;
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic,retain) NSArray<PLProgramUrl> *urlList; // type==2有集合，目前为图集url集合

@end

@protocol PLPrograms <NSObject>

@end

@interface PLPrograms : PLURLResponse
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSString *columnDesc;
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *payAmount;
@property (nonatomic) NSNumber *payAmount1;
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;
@property (nonatomic,retain) NSArray<PLProgram> *programList;
@end

