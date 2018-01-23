//
//  UIImage+ZFFilter.h
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZFFilter)
/**
 *  图片滤镜处理
 *
 *  @param image  UIImage类型
 *  @param radius 虚化参数
 *
 *  @return 虚化后的UIImage
 */
+ (UIImage *)filterWith:(UIImage *)image andRadius:(CGFloat)radius;
@end
