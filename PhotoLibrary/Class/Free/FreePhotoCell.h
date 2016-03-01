//
//  FreePhotoCell.h
//  PhotoLibrary
//
//  Created by ZF on 16/2/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FreePhotoCell : UICollectionViewCell
@property (nonatomic,strong) NSURL *imageURL;
- (void)setImageURL:(NSURL *)imageURL withFreeIcon:(BOOL)hasFreeIcon;
@end
