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

- (void)payForPayable:(id<PLPayable>)payable withCompletionHandler:(PLCompletionHandler)handler;
- (void)playVideo:(PLVideo *)video;
- (void)onPaymentNotification:(NSNotification *)notification;

@end
