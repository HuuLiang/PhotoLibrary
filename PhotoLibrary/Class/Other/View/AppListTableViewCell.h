//
//  AppListTableViewCell.h
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherApp.h"
@interface AppListTableViewCell : UITableViewCell

- (instancetype)setCellWithModel:(PLProgram *)model andIndexPath:(NSIndexPath *)indexPath antTableView:(UITableView *)tableView;
@end
