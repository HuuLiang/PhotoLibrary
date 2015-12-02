//
//  UIView+PLLoading.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PLLoading)

@property (nonatomic,retain,readonly) UIView *pl_loadingView;

- (void)pl_beginLoading;
- (void)pl_endLoading;

@end
