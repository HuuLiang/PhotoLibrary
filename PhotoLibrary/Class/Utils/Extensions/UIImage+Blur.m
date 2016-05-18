//
//  UIImage+Blur.m
//  YuePaoBa
//
//  Created by Sean Yue on 16/1/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "UIImage+Blur.h"
#import <GPUImage/GPUImage.h>

@implementation UIImage (Blur)

- (UIImage *)blurredImageWithRadius:(CGFloat)radius {
    GPUImagePicture *image = [[GPUImagePicture alloc] initWithImage:self];

    GPUImageiOSBlurFilter *filter = [[GPUImageiOSBlurFilter alloc] init];
    filter.blurRadiusInPixels = radius;
//    filter.downsampling = 8;
//    filter.saturation = 1.2;
    
    [image addTarget:filter];
    [filter useNextFrameForImageCapture];
    [image processImage];
    
    UIImage *outputImage = [filter imageFromCurrentFramebuffer];
    return outputImage;
}

@end
