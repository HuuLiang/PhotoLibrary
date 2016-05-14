//
//  AppListTableViewCell.m
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "AppListTableViewCell.h"

@interface AppListTableViewCell ()
{
    UIImageView *_AppImageView;

}
@end

@implementation AppListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _AppImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_AppImageView];
        _AppImageView.backgroundColor = [UIColor redColor];
        
        [_AppImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    
    return self;

}
- (instancetype)setCellWithModel:(PLProgram *)model andIndexPath:(NSIndexPath *)indexPath antTableView:(UITableView *)tableView{

    [_AppImageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:model.specialDesc]]) {
        NSLog(@"--------------------已安装");
    }
    return self;
    
}


@end
