//
//  UIView+PLDim.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "UIView+PLDim.h"
#import <objc/runtime.h>

static const void *kPLMaskViewAssociatedKey = &kPLMaskViewAssociatedKey;
static const CGFloat kPLMaskViewDimAnimationDuration = 0.3;

@implementation UIView (PLDim)

- (UIView *)pl_maskView {//蒙版
    UIView *maskView = objc_getAssociatedObject(self, kPLMaskViewAssociatedKey);
    if (maskView && [self.subviews containsObject:maskView]) {
        return maskView;
    }
    return nil;
}

- (UIView *)pl_dimView {
    UIView *maskView = objc_getAssociatedObject(self, kPLMaskViewAssociatedKey);
    if (!maskView) {
        maskView = [[UIView alloc] init];
        maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        @weakify(self);
        [maskView bk_whenTapped:^{
            @strongify(self);
            [self pl_restoreView];
        }];
        objc_setAssociatedObject(self, kPLMaskViewAssociatedKey, maskView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if ([self.subviews containsObject:maskView]) {
        return maskView;
    }
    
    maskView.frame = self.bounds;
    maskView.alpha = 0;
    [self addSubview:maskView];
    
    [UIView animateWithDuration:kPLMaskViewDimAnimationDuration animations:^{
        maskView.alpha = 1;
    }];
    return maskView;
}

- (void)pl_restoreView {
    if (self.pl_maskView) {
        [UIView animateWithDuration:kPLMaskViewDimAnimationDuration animations:^{
            self.pl_maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.pl_maskView removeFromSuperview];
        }];
    }
}

@end
