//
//  PLPopupMenuButton.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLPopupMenuButton : UIButton

@property (nonatomic) NSString *title;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) BOOL marked;

+ (instancetype)buttonWithTitle:(NSString *)title imageURL:(NSURL *)imageURL;
- (instancetype)initWithTitle:(NSString *)title imageURL:(NSURL *)imageURL;

@end
