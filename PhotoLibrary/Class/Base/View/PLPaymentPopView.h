//
//  PLPaymentPopView.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PLPaymentAction)(PLPaymentType type);

@interface PLPaymentPopView : UIView

@property (nonatomic,copy) PLPaymentAction action;
@property (nonatomic) double showPrice;

+ (instancetype)sharedInstance;

- (void)showInView:(UIView *)view;
- (void)hide;
@end
