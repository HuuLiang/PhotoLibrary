//
//  UIImage+ZFFilter.m
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "UIImage+ZFFilter.h"

@implementation UIImage (ZFFilter)

+ (UIImage *)filterWith:(UIImage *)image andRadius:(CGFloat)radius{
    
    CIImage *inputImage = [[CIImage alloc] initWithCGImage:image.CGImage];
    
    CIFilter *affineClampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    CGAffineTransform xform = CGAffineTransformMakeScale(1.0, 1.0);
    [affineClampFilter setValue:inputImage forKey:kCIInputImageKey];
    [affineClampFilter setValue:[NSValue valueWithBytes:&xform
                                               objCType:@encode(CGAffineTransform)]
                         forKey:@"inputTransform"];
    
    CIImage *extendedImage = [affineClampFilter valueForKey:kCIOutputImageKey];
    
    CIFilter *blurFilter =
    [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:extendedImage forKey:kCIInputImageKey];
    [blurFilter setValue:@(radius) forKey:@"inputRadius"];
    
    CIImage *result = [blurFilter valueForKey:kCIOutputImageKey];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    
    CGImageRef cgImage = [ciContext createCGImage:result fromRect:inputImage.extent];
    
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return uiImage;
}

@end
