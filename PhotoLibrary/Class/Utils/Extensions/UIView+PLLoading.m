//
//  UIView+PLLoading.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "UIView+PLLoading.h"
#import <objc/runtime.h>

static const void *kPLLoadingViewAssociatedKey = &kPLLoadingViewAssociatedKey;
static const void *kPLLoadingIndicatorAssociatedKey = &kPLLoadingIndicatorAssociatedKey;

@implementation UIView (PLLoading)

#pragma mark - 数据加载时候的view
- (UIView *)pl_loadingView {
    UIView *loadingView = objc_getAssociatedObject(self, kPLLoadingViewAssociatedKey);
    if (loadingView) {
        return loadingView;
    }
    
    loadingView = [[UIView alloc] init];
    loadingView.backgroundColor = [UIColor whiteColor];
    
    [self.pl_loadingIndicatorView startAnimating];
    [loadingView addSubview:self.pl_loadingIndicatorView];
    {
        [self.pl_loadingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(loadingView);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
    }
    objc_setAssociatedObject(self, kPLLoadingViewAssociatedKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return loadingView;
}
/**设置加载数据时候的大菊花*/
- (UIActivityIndicatorView *)pl_loadingIndicatorView {
    UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, kPLLoadingIndicatorAssociatedKey);
    if (indicatorView) {
        return indicatorView;
    }
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    objc_setAssociatedObject(self, kPLLoadingIndicatorAssociatedKey, indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return indicatorView;
}
/**开始加载数据*/
- (void)pl_beginLoading {
    if ([self.subviews containsObject:self.pl_loadingView]) {
        return ;
    }
    
    self.pl_loadingView.frame = self.bounds;
    [self addSubview:self.pl_loadingView];
}
/**结束加载数据时的调用*/
- (void)pl_endLoading {
    if ([self.subviews containsObject:self.pl_loadingView]) {
        [self.pl_loadingView removeFromSuperview];
    }
}

//- (void)layoutSubviews {
//    if ([self.subviews containsObject:self.pl_loadingView]) {
//        self.pl_loadingView.frame = self.bounds;
//    }
//    
//}
@end
