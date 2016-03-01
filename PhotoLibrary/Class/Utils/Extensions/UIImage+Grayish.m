//
//  UIImage+Grayish.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/10.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "UIImage+Grayish.h"

@implementation UIImage (Grayish)

// Transform the image in grayscale.
- (UIImage*) grayishImage {
    
    // Create a graphic context.
    UIGraphicsBeginImageContextWithOptions(self.size, YES, 1.0);
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [self drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
}

@end
