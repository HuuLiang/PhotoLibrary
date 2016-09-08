//
//  PLAccountViewController.m
//  PhotoLibrary
//
//  Created by ylz on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLAccountViewController.h"
#import "PLLoginViewController.h"
#import "PLChangePasswordVC.h"

@interface PLAccountViewController ()<UIAlertViewDelegate>
@property (nonatomic,weak)UITableViewCell *headerCell;
@property (nonatomic,weak)UITableViewCell *vipCell;
@property (nonatomic,weak)UITableViewCell *outAccountCell;
@property (nonatomic,weak)UITableViewCell *changePasswordCell;

@end

@implementation PLAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.layoutTableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.layoutTableView.hasRowSeparator = NO;
    self.layoutTableView.hasSectionBorder = NO;
    self.layoutTableView.scrollEnabled = NO;
    {
        [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    @weakify(self);
    self.layoutTableViewAction = ^(NSIndexPath *indexPath, UITableViewCell *cell){
        @strongify(self);
        if (cell == self->_headerCell || cell == self ->_vipCell) {
            id<PLPayable>payable = self.photo;
            [self payForPayable:payable appleProductId:PL_APPLEPAY_PICTURE_PRODUCTID payPointType:PLPayPointTypePictureVIP withCompletionHandler:nil];
        }else if(cell == self->_outAccountCell){
//           PLLoginViewController *loginVC = [[PLLoginViewController alloc] init];
//            if ([PLUtil isLogin]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"退出登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                [alertView show];
//                [self presentViewController:loginVC animated:YES completion:nil];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAccount];
//                [[NSUserDefaults standardUserDefaults ] removeObjectForKey:kUserPassword];
//                [[NSUserDefaults standardUserDefaults ] setObject:@"no" forKey:kUserLogin];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }else{
//                [self.navigationController pushViewController:loginVC animated:YES];
//            }
        }else if (cell == self->_changePasswordCell){
            PLChangePasswordVC *changePasswordVC = [[PLChangePasswordVC alloc] init];
            [self.navigationController pushViewController:changePasswordVC animated:YES];
        }
        
    };
    
    [self initCells];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaymentNotificationName object:nil];
    
}

- (void)onPaidNotification {
    [self initCells];
    [self.layoutTableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        PLLoginViewController *loginVC = [[PLLoginViewController alloc] init];
//        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:loginVC animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAccount];
        [[NSUserDefaults standardUserDefaults ] removeObjectForKey:kUserPassword];
        [[NSUserDefaults standardUserDefaults ] setObject:@"no" forKey:kUserLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

- (void)initCells {
    NSUInteger section = 0;
    UITableViewCell *headerCell = [[UITableViewCell alloc] init];
    self.headerCell = headerCell;
    headerCell.accessoryType = [PLUtil isPictureVip] ?UITableViewCellAccessoryNone: UITableViewCellAccessoryDisclosureIndicator;
    headerCell.selectionStyle = [PLUtil isPictureVip] ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    headerCell.backgroundColor = [UIColor whiteColor];
    NSString *imageStr = ![PLUtil isPictureVip] ? @"ktvip.jpg" : @"isvip.jpg";
    headerCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStr]];
    [self setLayoutCell:headerCell cellHeight:KWidth(150) inRow:0 andSection:section++];
    
    UITableViewCell *vipCell = [[UITableViewCell alloc] init];
    self.vipCell = vipCell;
    vipCell.accessoryType = UITableViewCellAccessoryNone;
    vipCell.selectionStyle = [PLUtil isPictureVip] ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    vipCell.imageView.image = [UIImage imageNamed:@"mine_vip_icon"];
    vipCell.textLabel.text = [PLUtil isPictureVip] ? @"VIP会员" : @"开通VIP";
    vipCell.textLabel.textColor = [PLUtil isPictureVip] ? [UIColor colorWithHexString:@"#dd0077"] : [UIColor blackColor];
    [self setLayoutCell:vipCell cellHeight:KWidth(54) inRow:0 andSection:section++];
    
    UITableViewCell *lineCell = [[UITableViewCell alloc] init];
    lineCell.backgroundColor = [UIColor lightGrayColor];
    [self setLayoutCell:lineCell cellHeight:0.5 inRow:0 andSection:section++];
    if ([PLUtil isLogin]) {
        
        UITableViewCell *changePasswordCell = [[UITableViewCell alloc] init];
        self.changePasswordCell = changePasswordCell;
        changePasswordCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        changePasswordCell.selectionStyle = UITableViewCellSelectionStyleGray;
        changePasswordCell.imageView.image = [UIImage imageNamed:@"changepaaword"];
        changePasswordCell.textLabel.text = @"修改密码";
        [self setLayoutCell:changePasswordCell cellHeight:KWidth(54) inRow:0 andSection:section++];
        
        UITableViewCell *lineCell2 = [[UITableViewCell alloc] init];
        lineCell2.backgroundColor = [UIColor lightGrayColor];
        [self setLayoutCell:lineCell2 cellHeight:0.5 inRow:0 andSection:section++];
    }
    
    UITableViewCell *outAccount = [[UITableViewCell alloc] init];
    self.outAccountCell = outAccount;
    outAccount.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    outAccount.selectionStyle = UITableViewCellSelectionStyleGray;
    outAccount.imageView.image = [UIImage imageNamed:@"loginout"];
    outAccount.textLabel.text = [PLUtil isLogin] ? @"退出登录" : @"登录";
    [self setLayoutCell:outAccount cellHeight:KWidth(54) inRow:0 andSection:section++];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
