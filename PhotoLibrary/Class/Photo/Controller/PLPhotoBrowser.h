//
//  PLPhotoBrowser.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/5.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLBaseViewController.h"

@class PLProgram;

@interface PLPhotoBrowser : PLBaseViewController

@property (nonatomic,retain) PLProgram *photoAlbum;

- (instancetype)initWithAlbum:(PLProgram *)album;
- (void)showInView:(UIView *)view;
- (void)hide;

@end
