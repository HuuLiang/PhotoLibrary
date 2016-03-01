//
//  PLChannelLockView.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/7.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLChannelLockView : UIView

@property (nonatomic) BOOL isLocked;
@property (nonatomic,retain) NSURL *imageURL;
@property (nonatomic,retain) NSString *title;

- (instancetype)initWithTitle:(NSString *)title imageURL:(NSURL *)imageURL isLocked:(BOOL)isLocked;

@end
