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
    UILabel *_installedLabel;
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
        
        [self installedLabel];
    }
    
    return self;

}

- (UILabel *)installedLabel {
 
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor grayColor];
    label.text = @"已安装";
    label.font = [UIFont systemFontOfSize:20.];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.hidden = YES;
    [_AppImageView addSubview:label];
    {
        [label mas_makeConstraints:^(MASConstraintMaker *make) {

            make.top.right.equalTo(_AppImageView);
            
        }];
    }
    _installedLabel = label;
    return label;
}

- (instancetype)setCellWithModel:(PLProgram *)model andIndexPath:(NSIndexPath *)indexPath antTableView:(UITableView *)tableView{

    [_AppImageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg]];
    
    
    [PLUtil checkAppInstalledWithBundleId:model.specialDesc completionHandler:^(BOOL installed) {
        if (installed) {
            _installedLabel.hidden = YES;
        }else{
            _installedLabel.hidden = NO;
        }
    }];
    
    return self;
    
}


@end
