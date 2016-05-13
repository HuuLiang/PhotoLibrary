//
//  UIImage+ZFFilter.h
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZFFilter)
+ (UIImage *)filterWith:(UIImage *)image andRadius:(CGFloat)radius;
@end
