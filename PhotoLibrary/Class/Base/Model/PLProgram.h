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

#pragma mark - 单个cell上的节目模型中数组的每个元素对应的属性
@protocol PLProgramUrl <NSObject>

@end

@interface PLProgramUrl : NSObject//单个cell上的模型中数组的每个元素对应的属性
@property (nonatomic) NSNumber *programUrlId; //节目URLID
@property (nonatomic) NSString *title; //标题
@property (nonatomic) NSString *url; //图片路径
@property (nonatomic) NSNumber *width; //宽度
@property (nonatomic) NSNumber *height;//高度
@end



#pragma mark - 单个cell上的节目模型
@protocol PLProgram <NSObject>

@end

@interface PLProgram : NSObject//单个cell上的模型，单个节目的model

@property (nonatomic) NSNumber *programId;//节目id
@property (nonatomic) NSString *title; //节目名称
@property (nonatomic) NSString *specialDesc; //节目描述
@property (nonatomic) NSString *videoUrl;//视频路径 type 有值
@property (nonatomic) NSString *coverImg; //封面图片
@property (nonatomic) BOOL isHot;
@property (nonatomic) NSNumber *type; // 1、视频 2、图片、3、广告
@property (nonatomic,retain) NSArray<PLProgramUrl> *urlList; // type==2有集合，目前为图集url集合

@end


#pragma mark - 数据请求一次，返回的模型
@protocol PLPrograms <NSObject>

@end

@interface PLPrograms : PLURLResponse//数据请求一次，返回的模型
@property (nonatomic) NSNumber *columnId; //栏目ID
@property (nonatomic) NSString *name;  //栏目名称
@property (nonatomic) NSString *columnImg;//栏目图片
@property (nonatomic) NSString *columnDesc; //栏目描述
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *payAmount;//支付多少钱
@property (nonatomic) NSNumber *payAmount1;
@property (nonatomic) NSNumber *items; //总条数
@property (nonatomic) NSNumber *page;  //当前页码
@property (nonatomic) NSNumber *pageSize;//每一页的数量
@property (nonatomic,retain) NSArray<PLProgram> *programList;//频道加载一次后返回的cell的对应的属性........节目数组
@end

