//
//  PLBaseViewController.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLPayable.h"

@class PLVideo;
@interface PLBaseViewController : UIViewController
@property (nonatomic) BOOL bottomAdBanner;
@property (nonatomic) CGFloat adBannerHeight;
//@property (nonatomic)NSString *appleProductId;//内购

- (void)payForPayable:(id<PLPayable>)payable appleProductId:(NSString *)appleProductId payPointType:(PLPayPointType)payPointType withCompletionHandler:(PLCompletionHandler)handler;
- (void)payForPayable:(id<PLPayable>)payable withBeginAction:(PLAction)beginAction appleProductId:(NSString *)appleProductId  payPointType:(PLPayPointType)payPointType completionHandler:(PLCompletionHandler)completionHandler;

- (void)playVideo:(PLVideo *)video;
- (void)onPaymentNotification:(NSNotification *)notification;

@end
