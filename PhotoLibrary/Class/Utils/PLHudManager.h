//
//  PLHudManager.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLHudManager : NSObject

+(instancetype)manager;
-(void)showHudWithText:(NSString *)text;
-(void)showHudWithTitle:(NSString *)title message:(NSString *)msg;

@end
