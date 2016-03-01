//
//  PLCollectionViewLayout.h
//  PhotoLibrary
//
//  Created by ZF on 16/2/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PLfreeCollectionViewDelegate <NSObject>

@optional
- (BOOL) collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout hasAdBannerForItem:(NSUInteger)item;
@end


@interface PLCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGFloat interItemSpacing;
@property (nonatomic,weak,nullable) id <PLfreeCollectionViewDelegate>delegate;
@end
