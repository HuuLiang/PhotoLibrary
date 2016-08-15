//
//  PLChangePasswordVC.m
//  PhotoLibrary
//
//  Created by ylz on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLChangePasswordVC.h"

@interface PLChangePasswordVC ()

@end

@implementation PLChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(popToLoginView)];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    self.layoutTableView.backgroundColor = [UIColor whiteColor];
    self.layoutTableView.hasRowSeparator = NO;
    self.layoutTableView.hasSectionBorder = YES;
    {
    [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(KWidth(30.));
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(CGRectGetMaxX(self.view.bounds), KWidth(200)));
    }];
    }
    
    [self initCell];
}
- (void)popToLoginView {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)initCell {
    NSInteger rowIndex = 0;
    UITableViewCell *oldPassWordCell = [[UITableViewCell alloc] init];
    oldPassWordCell.accessoryType = UITableViewCellAccessoryNone;
    oldPassWordCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setLayoutCell:oldPassWordCell cellHeight:KWidth(50) inRow:rowIndex++ andSection:0];
    
    UILabel *oldPassWordLabel = [[UILabel alloc] init];
    oldPassWordLabel.text = @"原密码:";
    [oldPassWordCell addSubview:oldPassWordLabel];
    UITextField *oldPasswordField = [[UITextField alloc] init];
    oldPasswordField.placeholder = @"请输入原密码";
    [oldPassWordCell addSubview:oldPasswordField];
    
    {
    [oldPassWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(oldPassWordCell).mas_offset(KWidth(10.));
        make.centerY.mas_equalTo(oldPassWordCell);
    }];
        
        [oldPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(oldPassWordLabel.mas_right).mas_offset(KWidth(2.5));
            make.centerY.mas_equalTo(oldPassWordCell);
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
