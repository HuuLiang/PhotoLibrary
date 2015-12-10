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

- (BOOL)payForPayable:(id<PLPayable>)payable;
- (void)playVideo:(PLVideo *)video;
- (void)onPaymentNotification:(NSNotification *)notification;

@end
