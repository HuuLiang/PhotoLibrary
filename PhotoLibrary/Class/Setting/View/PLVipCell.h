//
//  PLVipCell.h
//  PhotoLibrary
//
//  Created by Liang on 16/7/1.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^payBtnBlock)();

@interface PLVipCell : UITableViewCell

@property (nonatomic) NSString *bgImg;
@property (nonatomic) NSString* price;

@property (nonatomic) NSString *payBtnStr;

@property (nonatomic,copy)payBtnBlock payBtnblock;


@end
