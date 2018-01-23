//
//  UIScrollView+Refish.h
//  PhotoLibrary
//
//  Created by ZF on 16/2/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (Refish)
- (void)PL_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)PL_triggerPullToRefresh;
- (void)PL_endPullToRefresh;

- (void)PL_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)PL_pagingRefreshNoMoreData;
@end
