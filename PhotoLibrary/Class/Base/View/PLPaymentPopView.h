//
//  PLPaymentPopView.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PLPaymentAction)(PLPaymentType type,PLPaymentType subType);
typedef void (^PLBackAction)(void);

@interface PLPaymentPopView : UIView

@property (nonatomic) PLPaymentUsage usage;
@property (nonatomic,copy) PLPaymentAction paymentAction;
@property (nonatomic,copy) PLBackAction backAction;

@property (nonatomic) NSNumber *showPrice;
@property (nonatomic,readonly) CGSize contentSize;

+ (instancetype)sharedInstance;

- (void)showInView:(UIView *)view;
- (void)hide;
@end
