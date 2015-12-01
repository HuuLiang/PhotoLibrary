//
//  PLProgram.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLProgram.h"

@implementation PLProgramUrl

@end

@implementation PLProgram

- (Class)urlListElementClass {
    return [PLProgramUrl class];
}

@end

@implementation PLPrograms

- (Class)programListElementClass {
    return [PLProgram class];
}

@end
