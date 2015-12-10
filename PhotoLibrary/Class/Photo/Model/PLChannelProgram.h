//
//  PLChannelProgram.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLProgram.h"

@interface PLChannelProgram : PLProgram
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;
@end

@interface PLChannelPrograms : PLPrograms <PLPayable>

@end