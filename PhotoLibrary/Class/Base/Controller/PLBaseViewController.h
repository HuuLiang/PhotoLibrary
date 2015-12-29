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

typedef void (^PLPaymentCompletionHandler)(BOOL success);

@interface PLBaseViewController : UIViewController

- (void)payForPayable:(id<PLPayable>)payable withCompletionHandler:(PLPaymentCompletionHandler)handler;
- (void)playVideo:(PLVideo *)video;
- (void)onPaymentNotification:(NSNotification *)notification;

@end
