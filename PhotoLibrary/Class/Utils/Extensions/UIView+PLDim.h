//
//  UIView+PLDim.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PLDim)

@property (nonatomic,retain,readonly) UIView *pl_maskView;

- (UIView *)pl_dimView;
- (void)pl_restoreView;

@end
