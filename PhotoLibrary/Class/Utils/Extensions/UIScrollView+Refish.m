//
//  UIScrollView+Refish.m
//  PhotoLibrary
//
//  Created by ZF on 16/2/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "UIScrollView+Refish.h"
#import <MJRefresh.h>
@implementation UIScrollView (Refish)
- (void)PL_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.header) {
        MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
        refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        self.header = refreshHeader;
    }
}

- (void)PL_triggerPullToRefresh {
    [self.header beginRefreshing];
}

- (void)PL_endPullToRefresh {
    [self.header endRefreshing];
    [self.footer resetNoMoreData];
}

- (void)PL_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        self.footer = refreshFooter;
    }
}

- (void)PL_pagingRefreshNoMoreData {
    [self.footer endRefreshingWithNoMoreData];
}

@end
