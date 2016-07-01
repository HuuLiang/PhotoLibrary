//
//  PLLayoutTableViewController.h
//  PhotoLibrary
//
//  Created by Liang on 16/7/1.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLBaseViewController.h"

typedef void (^PLLayoutTableViewAction)(NSIndexPath *indexPath, UITableViewCell *cell);

@interface PLLayoutTableViewController : PLBaseViewController <UITableViewSeparatorDelegate,UITableViewDataSource>

@property (nonatomic,retain,readonly) UITableView *layoutTableView;
@property (nonatomic,copy) PLLayoutTableViewAction layoutTableViewAction;

// Cell & Cell Height
- (void)setLayoutCell:(UITableViewCell *)cell
                inRow:(NSUInteger)row
           andSection:(NSUInteger)section;

- (void)setLayoutCell:(UITableViewCell *)cell
           cellHeight:(CGFloat)height
                inRow:(NSUInteger)row
           andSection:(NSUInteger)section;

- (void)removeAllLayoutCells;

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)cellHeightAtIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary<NSIndexPath *, UITableViewCell *> *)allCells;

// Header height & title
- (void)setHeaderHeight:(CGFloat)height inSection:(NSUInteger)section;
- (void)setHeaderTitle:(NSString *)title height:(CGFloat)height inSection:(NSUInteger)section;


@end
