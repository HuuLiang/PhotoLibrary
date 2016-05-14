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

/**
 *  栏目的cell
 *
 *  @param indexpath
 *  @param collectionView
 *  @param model          栏目
 *  @param hasTitle       是否有标题
 *  @param hasPayed       是否支付过改栏目所在的频道
 *
 *  @return
 */
- (instancetype)setCellWithIndexPath:(NSIndexPath *)indexpath
                   andCollectionView:(UICollectionView *)collectionView
                            andModel:(id)model
                            hasTitle:(BOOL)hasTitle
                            hasPayed:(BOOL)hasPayed;


/**
 *  频道的cell
 *
 *  @param indexpath
 *  @param collectionView
 *  @param model          频道模型
 *  @param hasTitle       是否有标题
 *
 *  @return 
 */
- (instancetype)setChannelCellWithIndexPath:(NSIndexPath *)indexpath
                          andCollectionView:(UICollectionView *)collectionView andModel:(PLPhotoChannel *)model
                                   hasTitle:(BOOL)hasTitle ;
@end
