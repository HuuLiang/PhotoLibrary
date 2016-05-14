//
//  PLPhotoCell.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLProgram.h"
#import "PLPhotoChannel.h"
@interface PLPhotoCell : UICollectionViewCell

@property (nonatomic,retain) NSURL *imageURL;

- (instancetype)setCellWithIndexPath:(NSIndexPath *)indexpath andCollectionView:(UICollectionView *)collectionView andModel:(id)model hasTitle:(BOOL)hasTitle;

- (instancetype)setChannelCellWithIndexPath:(NSIndexPath *)indexpath andCollectionView:(UICollectionView *)collectionView andModel:(PLPhotoChannel *)model hasTitle:(BOOL)hasTitle;
@end
