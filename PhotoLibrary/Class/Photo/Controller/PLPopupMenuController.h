//
//  PLPopupMenuController.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLBaseViewController.h"

@interface PLPopupMenuItem : NSObject
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *imageUrlString;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL occupied;

+ (instancetype)menuItemWithTitle:(NSString *)title imageUrlString:(NSString *)urlString;

@end

typedef void (^PLPopupMenuSelectAction)(NSUInteger index, id sender);

@interface PLPopupMenuController : PLBaseViewController

@property (nonatomic,copy) PLPopupMenuSelectAction selectAction;
@property (nonatomic,retain) NSArray<PLPopupMenuItem *> *menuItems;

- (instancetype)initWithMenuItems:(NSArray<PLPopupMenuItem *> *)menuItems;
- (void)showInView:(UIView *)view inPosition:(CGPoint)pos; // pos: left-bottom point
- (void)showInWindowInPosition:(CGPoint)pos;
- (void)hide;

@end
