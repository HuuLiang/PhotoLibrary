//
//  PLBaseViewController.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

@class PLProgram;

#import <UIKit/UIKit.h>

@interface PLBaseViewController : UIViewController

- (void)switchToPlayProgram:(PLProgram *)program;
- (void)payForProgram:(PLProgram *)program
        shouldPopView:(BOOL)popped
withCompletionHandler:(void (^)(BOOL success))handler;

@end
