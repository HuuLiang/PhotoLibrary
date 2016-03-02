//
//  PLCollectionViewLayout.m
//  PhotoLibrary
//
//  Created by ZF on 16/2/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLCollectionViewLayout.h"
static const CGFloat kPhotoCellInterspace = 5;
//typedef NSMutableDictionary<NSIndexPath *,UICollectionViewLayoutAttributes*> LayoutAttributesMutableDictionary;
@interface PLCollectionViewLayout ()
//@property (nonatomic,strong) LayoutAttributesMutableDictionary *layoutAttributes;
@property (nonatomic,assign) CGSize collectionViewContentSize;
@property (nonatomic,strong) NSMutableArray<UICollectionViewLayoutAttributes*> *attsArray;
@end
@implementation PLCollectionViewLayout

//DefineLazyPropertyInitialization(LayoutAttributesMutableDictionary, layoutAttributes);
DefineLazyPropertyInitialization(NSMutableArray, attsArray);

- (CGSize)adBannerSize {
    const CGFloat cvW = CGRectGetWidth(self.collectionView.bounds);
    return CGSizeMake(cvW, cvW/5);
}

- (CGSize)nomalSize{
    return CGSizeMake(self.collectionView.frame.size.width/2 - kPhotoCellInterspace , (self.collectionView.frame.size.width/2 - kPhotoCellInterspace)/(345/423.));//345/423.宽高比
}

/**准备工作*/
- (void)prepareLayout//执行一次
{
    [super prepareLayout];
    
//    [self.layoutAttributes removeAllObjects];
    [self.attsArray removeAllObjects];
    
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    if (numberOfItems == 0) {
        return;
    }
    
    CGRect lastLayerFrame = CGRectMake(1, 1, 0, 0);//随便写的初始值
    
    for (int i = 0; i< numberOfItems; ++i) {

        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];

        if ([self hasAdBannerForItem:i]) {//是广告
            layoutAttributes.frame = CGRectMake(0, CGRectGetMaxY(lastLayerFrame)+self.interItemSpacing, self.adBannerSize.width, self.adBannerSize.height);
        }
        else{//不是广告
            CGFloat x = 0,y = 0;
            
            if(lastLayerFrame.origin.x==0&&lastLayerFrame.size.height!=self.adBannerSize.height){//放右边
                 x = CGRectGetMaxX(lastLayerFrame)+self.interItemSpacing;
                 y = lastLayerFrame.origin.y;
                
            }else{//放左边
                 x = 0;
                 y = CGRectGetMaxY(lastLayerFrame)+self.interItemSpacing;
            }
            
            layoutAttributes.frame = CGRectMake(x, y, self.nomalSize.width, self.nomalSize.height);
        
        };
        
        if (!CGRectEqualToRect(layoutAttributes.frame, CGRectZero)) {//frame有大小
            lastLayerFrame = layoutAttributes.frame;
            
//            [self.layoutAttributes setObject:layoutAttributes forKey:layoutAttributes.indexPath];
            [self.attsArray addObject:layoutAttributes];
        }
        
    }
    self.collectionViewContentSize = CGSizeMake(self.collectionView.bounds.size.width, CGRectGetMaxY(lastLayerFrame));//设置contentsize的大小，没这个不能滚动
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {//会执行两次
    
    return self.attsArray;
//    return [self.layoutAttributes.allValues bk_select:^BOOL(id obj) {
//        UICollectionViewLayoutAttributes *attributes = obj;
//        return CGRectIntersectsRect(rect, attributes.frame);
//    }];
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {//这个方法没有调用过
//    
//    return self.layoutAttributes[indexPath];//字典
//    
//}
/**判断是否是广告view*/
- (BOOL)hasAdBannerForItem:(NSUInteger)item {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:hasAdBannerForItem:)]) {
        return [self.delegate collectionView:self.collectionView layout:self hasAdBannerForItem:item];//返回代理方法结果
    }
    return NO;
}

@end
