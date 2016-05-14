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
- (instancetype)setCellWithModel:(OtherApp *)model andIndexPath:(NSIndexPath *)indexPath antTableView:(UITableView *)tableView{

    return self;
    
}


@end
