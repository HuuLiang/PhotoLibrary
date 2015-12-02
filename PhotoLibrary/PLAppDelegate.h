//
//  PLAppDelegate.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)paidWithOrderId:(NSString *)orderId
                  price:(NSString *)price
                 result:(NSInteger)result
           forProgramId:(NSString *)programId
            programType:(NSString *)programType
           payPointType:(NSString *)payPointType
            paymentType:(PLPaymentType)paymentType;

@end

