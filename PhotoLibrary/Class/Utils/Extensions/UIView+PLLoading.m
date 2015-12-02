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

@implementation UIView (PLLoading)

- (UIView *)pl_loadingView {
    UIView *loadingView = objc_getAssociatedObject(self, kPLLoadingViewAssociatedKey);
    if (loadingView) {
        return loadingView;
    }
    
    loadingView = [[UIView alloc] init];
    loadingView.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    [loadingView addSubview:indicatorView];
    {
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(loadingView);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
    }
    objc_setAssociatedObject(self, kPLLoadingViewAssociatedKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return loadingView;
}

- (void)pl_beginLoading {
    if ([self.subviews containsObject:self.pl_loadingView]) {
        return ;
    }
    
    //self.pl_loadingView.frame = self.bounds;
    [self addSubview:self.pl_loadingView];
}

- (void)pl_endLoading {
    if ([self.subviews containsObject:self.pl_loadingView]) {
        [self.pl_loadingView removeFromSuperview];
    }
}

- (void)layoutSubviews {
    if ([self.subviews containsObject:self.pl_loadingView]) {
        self.pl_loadingView.frame = self.bounds;
    }
    
}
@end
