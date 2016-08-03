//
//  PLPaymentPopView.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPaymentPopView.h"
#import <objc/runtime.h>

static const CGFloat kHeaderImageScale = 1.5;
//static const CGFloat kFooterImageScale = 1065./108.;
static const CGFloat kCellHeight = 60;
static const void* kPaymentButtonAssociatedKey = &kPaymentButtonAssociatedKey;

@interface PLPaymentPopView () <UITableViewDataSource,UITableViewSeparatorDelegate>
{
    UITableViewCell *_headerCell;
    UITableViewCell *_footerCell;
    
    UIImageView *_headerImageView;
    UIImageView *_footerImageView;
    UILabel *_priceLabel;
}
@property (nonatomic,retain) NSMutableDictionary<NSIndexPath *, UITableViewCell *> *cells;
@end

@implementation PLPaymentPopView

DefineLazyPropertyInitialization(NSMutableDictionary, cells)

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
        self.layer.cornerRadius = 33;
        self.layer.masksToBounds = YES;
        
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        self.hasRowSeparator = YES;
        self.hasSectionBorder = YES;
        self.priceColor = [UIColor redColor];
    }
    return self;
}

- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width {
    const CGFloat headerImageHeight = width / kHeaderImageScale;
    //    const CGFloat footerImageHeight = kCellHeight;
    
    __block CGFloat cellHeights = headerImageHeight;//+footerImageHeight;
    [self.cells enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * _Nonnull key, UITableViewCell * _Nonnull obj, BOOL * _Nonnull stop) {
        cellHeights += [self tableView:self heightForRowAtIndexPath:key];
    }];
    
    cellHeights += [self tableView:self heightForHeaderInSection:1];
    cellHeights += 15;
    return cellHeights;
}

- (void)addPaymentWithImage:(UIImage *)image
                      title:(NSString *)title
                  available:(BOOL)available
                     action:(PLPaymentAction)action
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.cells.count inSection:1];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [cell addSubview:imageView];
    {
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell);
            make.left.equalTo(cell).offset(15);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
    }
    
    UIButton *button;
    if (available) {
        button = [[UIButton alloc] init];
        objc_setAssociatedObject(cell, kPaymentButtonAssociatedKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        UIImage *buttonImage = [UIImage imageNamed:@"payment_normal_button"];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"payment_highlight_button"] forState:UIControlStateHighlighted];
        [cell addSubview:button];
        {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell);
                make.right.equalTo(cell).offset(-15);
                make.height.equalTo(cell).multipliedBy(0.9);
                make.width.equalTo(button.mas_height).multipliedBy(buttonImage.size.width/buttonImage.size.height);
            }];
        }
        [button bk_addEventHandler:^(id sender) {
            if (action) {
                action(sender);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = title;
    [cell addSubview:titleLabel];
    {
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).offset(15);
            make.centerY.equalTo(cell);
            make.right.equalTo(button?button.mas_left:cell).offset(-15);
        }];
    }
    
    [self.cells setObject:cell forKey:indexPath];
}

- (void)setHeaderImage:(NSString *)headerImage {
    _headerImage = headerImage;
//    if ([PLUtil isAppleStore]) {
//        
//        _headerImageView.image = [UIImage imageNamed:@"appstore_image.jpg"];
//    }else {
//        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:headerImage]];
//    }
    
}

- (void)setShowPrice:(NSNumber *)showPrice {
    _showPrice = showPrice;
    [self priceLabelSetPrice:showPrice];
}

- (void)priceLabelSetPrice:(NSNumber *)priceNumber {
    if (!priceNumber) {
        return;
    }
    double price = priceNumber.doubleValue;
    BOOL showInteger = (NSUInteger)(price * 100) % 100 == 0;
    _priceLabel.text = showInteger ? [NSString stringWithFormat:@"%ld", (NSUInteger)price] : [NSString stringWithFormat:@"%.2f", price];
}

- (void)setPriceColor:(UIColor *)priceColor {
    _priceColor = priceColor;
    _priceLabel.textColor = priceColor;
}
#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!_headerCell) {
            _headerCell = [[UITableViewCell alloc] init];
            _headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            _headerImageView = [[UIImageView alloc] init];//WithImage:[UIImage imageNamed:_headerImage]
            
            if ([PLUtil isAppleStore]) {
                _headerImageView.image = [UIImage imageNamed:_headerImage];
            }else {
            
                [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_headerImage]];
            }
            
            [_headerCell addSubview:_headerImageView];
            {
                [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(_headerCell);
                }];
            }
            
            _priceLabel = [[UILabel alloc] init];
            _priceLabel.textColor = [UIColor redColor];
            _priceLabel.font = [UIFont systemFontOfSize:18.];
            _priceLabel.textAlignment = NSTextAlignmentCenter;
            _priceLabel.textColor = _priceColor;
            [self priceLabelSetPrice:_showPrice];
            [_headerImageView addSubview:_priceLabel];
            {
                [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_headerImageView).multipliedBy(1.5);
                    make.centerX.equalTo(_headerImageView).multipliedBy(0.42);
                    make.width.equalTo(_headerImageView).multipliedBy(0.1);
                }];
            }
            
            UIButton *closeButton = [[UIButton alloc] init];
            closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [closeButton setImage:[UIImage imageNamed:@"payment_back"] forState:UIControlStateNormal];
            [_headerCell addSubview:closeButton];
            {
                [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_headerCell).offset(5);
                    make.left.equalTo(_headerCell).offset(5);
                    make.size.mas_equalTo(CGSizeMake(60, 60));
                }];
            }
            
            @weakify(self);
            [closeButton bk_addEventHandler:^(id sender) {
                @strongify(self);
                if (self.closeAction) {
                    self.closeAction(sender);
                }
            } forControlEvents:UIControlEventTouchUpInside];
        }
        return _headerCell;
        //    } else if (indexPath.section == 2) {
        //        if (!_footerCell) {
        //            _footerCell = [[UITableViewCell alloc] init];
        //            _footerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        //            
        //            _footerImageView = [[UIImageView alloc] initWithImage:_footerImage];
        //            [_footerCell addSubview:_footerImageView];
        //            {
        //                [_footerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        //                    make.center.equalTo(_footerCell);
        //                    make.height.equalTo(_footerCell).multipliedBy(0.45);
        //                    make.width.equalTo(_footerImageView.mas_height).multipliedBy(kFooterImageScale);
        //                }];
        //            }
        //        }
        //        return _footerCell;
    } else {
        return self.cells[indexPath];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.cells.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGRectGetWidth(tableView.bounds) / kHeaderImageScale;
    } else {
        return kCellHeight;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"选择支付方式";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 30;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *paymentButton = objc_getAssociatedObject(cell, kPaymentButtonAssociatedKey);
    paymentButton.highlighted = NO;
    [paymentButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *paymentButton = objc_getAssociatedObject(cell, kPaymentButtonAssociatedKey);
    paymentButton.highlighted = YES;
}
@end
