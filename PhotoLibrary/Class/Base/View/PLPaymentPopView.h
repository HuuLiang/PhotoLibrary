//
//  PLPaymentPopView.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PLPaymentAction)(id sender);

@interface PLPaymentPopView : UITableView

@property (nonatomic,retain) UIImage *headerImage;
//@property (nonatomic,retain) UIImage *footerImage;
@property (nonatomic,copy) PLPaymentAction closeAction;
@property (nonatomic) NSNumber *showPrice;
@property (nonatomic,retain) UIColor *priceColor;

- (void)addPaymentWithImage:(UIImage *)image title:(NSString *)title available:(BOOL)available action:(PLPaymentAction)action;
- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width;

@end
