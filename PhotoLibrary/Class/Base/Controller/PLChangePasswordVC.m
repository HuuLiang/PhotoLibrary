//
//  PLChangePasswordVC.m
//  PhotoLibrary
//
//  Created by ylz on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLChangePasswordVC.h"

@interface PLChangePasswordVC ()

@property (nonatomic,weak) UITextField *oldPasswordField;
@property (nonatomic,weak) UITextField *firstNewPasswordField;
@property (nonatomic,weak) UITextField *thirdNewPasswordField;

@end

@implementation PLChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(popToLoginView)];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    self.layoutTableView.backgroundColor = [UIColor whiteColor];
    self.layoutTableView.hasRowSeparator = YES;
    self.layoutTableView.hasSectionBorder = NO;
    self.layoutTableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    {
        [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            //        make.top.mas_equalTo(self.view).mas_offset(KWidth(30.));
            //        make.centerX.mas_equalTo(self.view);
            //        make.size.mas_equalTo(CGSizeMake(CGRectGetMaxX(self.view.bounds), KWidth(200)));
            make.edges.mas_equalTo(self.view);
        }];
    }
    
    [self.layoutTableView bk_whenTapped:^{
        [_oldPasswordField resignFirstResponder];
        [_firstNewPasswordField resignFirstResponder];
        [_thirdNewPasswordField resignFirstResponder];
    }];
    
    [self initCell];
}
- (void)popToLoginView {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)initCell{
    NSInteger row = 0;
    [self initOldPasswordCellWithRowIndex:row++];
    [self initFirestNewPasswordCellWithRowIndex:row++];
    [self initThirdNewPasswordCellWithRowIndex:row++];
    [self initChangeBtnCell];
    
}

- (void)initOldPasswordCellWithRowIndex:(NSInteger)rowIndex{
    UITableViewCell* oldPasswordCell = [[UITableViewCell alloc] init];
    oldPasswordCell.accessoryType = UITableViewCellAccessoryNone;
    oldPasswordCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setLayoutCell:oldPasswordCell cellHeight:KWidth(50) inRow:rowIndex andSection:0];
    
    UILabel *PassWordLabel = [[UILabel alloc] init];
    PassWordLabel.text = @"原密码:";
    [oldPasswordCell addSubview:PassWordLabel];
    UITextField* oldPasswordField = [[UITextField alloc] init];
    self.oldPasswordField = oldPasswordField;
    oldPasswordField.placeholder = @"请输入原密码";
    oldPasswordField.keyboardType = UIKeyboardTypeASCIICapable;
    oldPasswordField.secureTextEntry = YES;
    oldPasswordField.clearButtonMode = UITextFieldViewModeAlways;
    [oldPasswordCell addSubview:oldPasswordField];
    
    {
        [PassWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(oldPasswordCell).mas_offset(KWidth(15.));
            make.centerY.mas_equalTo(oldPasswordCell);
            make.width.mas_equalTo(KWidth(60.));
        }];
        
        
        [oldPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(PassWordLabel.mas_right).mas_offset(KWidth(5.));
            make.centerY.mas_equalTo(oldPasswordCell);
            make.width.mas_equalTo(KWidth(300.));
        }];
    }
}

- (void)initFirestNewPasswordCellWithRowIndex:(NSInteger)rowIndex{
    UITableViewCell *  firstNewPasswordCell = [[UITableViewCell alloc] init];
    firstNewPasswordCell.accessoryType = UITableViewCellAccessoryNone;
    firstNewPasswordCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setLayoutCell:firstNewPasswordCell cellHeight:KWidth(50) inRow:rowIndex andSection:0];
    
    UILabel *PassWordLabel = [[UILabel alloc] init];
    PassWordLabel.text = @"新密码:";
    [firstNewPasswordCell addSubview:PassWordLabel];
    UITextField * firstNewPasswordField = [[UITextField alloc] init];
    self.firstNewPasswordField = firstNewPasswordField;
    firstNewPasswordField.keyboardType = UIKeyboardTypeASCIICapable;
    firstNewPasswordField.secureTextEntry = YES;
    firstNewPasswordField.clearButtonMode = UITextFieldViewModeAlways;
    firstNewPasswordField.placeholder = @"请输入新密码";
    [firstNewPasswordCell addSubview:firstNewPasswordField];
    
    {
        [PassWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(firstNewPasswordCell).mas_offset(KWidth(15.));
            make.centerY.mas_equalTo(firstNewPasswordCell);
            make.width.mas_equalTo(KWidth(60.));
        }];
        
        [firstNewPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(PassWordLabel.mas_right).mas_offset(KWidth(5.));
            make.centerY.mas_equalTo(firstNewPasswordCell);
            make.width.mas_equalTo(KWidth(300.));
        }];
    }
    
}

- (void)initThirdNewPasswordCellWithRowIndex:(NSInteger)rowIndex{
    UITableViewCell* thirdNewPasswordCell = [[UITableViewCell alloc] init];
    thirdNewPasswordCell.accessoryType = UITableViewCellAccessoryNone;
    thirdNewPasswordCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setLayoutCell:thirdNewPasswordCell cellHeight:KWidth(50) inRow:rowIndex andSection:0];
    
    UILabel *oldPassWordLabel = [[UILabel alloc] init];
    oldPassWordLabel.text = @"新密码:";
    [thirdNewPasswordCell addSubview:oldPassWordLabel];
    UITextField* thirdNewPasswordField = [[UITextField alloc] init];
    self.thirdNewPasswordField = thirdNewPasswordField;
    thirdNewPasswordField.keyboardType = UIKeyboardTypeASCIICapable;
    thirdNewPasswordField.secureTextEntry = YES;
    thirdNewPasswordField.clearButtonMode = UITextFieldViewModeAlways;
    thirdNewPasswordField.placeholder = @"请输入新密码";
    [thirdNewPasswordCell addSubview:thirdNewPasswordField];
    
    {
        [oldPassWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(thirdNewPasswordCell).mas_offset(KWidth(15.));
            make.centerY.mas_equalTo(thirdNewPasswordCell);
            make.width.mas_equalTo(KWidth(60.));
        }];
        
        [thirdNewPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(oldPassWordLabel.mas_right).mas_offset(KWidth(5.));
            make.centerY.mas_equalTo(thirdNewPasswordCell);
            make.width.mas_equalTo(KWidth(300.));
            
        }];
    }
    
}

- (void)initChangeBtnCell{
    UITableViewCell * changeCell = [[UITableViewCell alloc] init];
    changeCell.accessoryType = UITableViewCellAccessoryNone;
    changeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    changeCell.backgroundColor = [UIColor whiteColor];
    
    [self setLayoutCell:changeCell cellHeight:KWidth(100.) inRow:0 andSection:1];
    
    UIButton *changeBtn = [[UIButton alloc] init];
    [changeBtn setTitle:@"修改密码" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    changeBtn.backgroundColor = [UIColor colorWithHexString:@"#ff680d"];
    changeBtn.titleLabel.font = [UIFont systemFontOfSize:KWidth(18.)];
    changeBtn.layer.cornerRadius = 5.;
    changeBtn.clipsToBounds = YES;
    [changeCell addSubview:changeBtn];
    [changeBtn bk_addEventHandler:^(id sender) {
        
        if (_oldPasswordField.text.length >=6 && _firstNewPasswordField.text.length >=6 && _thirdNewPasswordField.text.length >= 6 &&_oldPasswordField.text.length<=12 && _firstNewPasswordField.text.length<= 12 && _thirdNewPasswordField.text.length<=12) {
            
            if ([_thirdNewPasswordField.text  isEqualToString:_firstNewPasswordField.text]) {
                
                if ([self isHaveNoneChineseWithText:_oldPasswordField.text] && [self isHaveNoneChineseWithText:_firstNewPasswordField.text] && [self isHaveNoneChineseWithText:_thirdNewPasswordField.text]) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:_firstNewPasswordField.text forKey:kUserPassword];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.navigationController popViewControllerAnimated:YES];
                    [[PLHudManager manager] showHudWithText:@"修改密码成功"];
                    
                }else {
                    [[PLHudManager manager] showHudWithText:@"只能输入字母和数字"];
                }
                
            }else {
                [[PLHudManager manager] showHudWithText:@"两次输入的密码不同,请核对"];
            }
        } else {
            
            [[PLHudManager manager] showHudWithText:@"账号密码长度6-12个字符之间"];
        }
        
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    {
        [changeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(changeCell);
            make.size.mas_equalTo(CGSizeMake(KWidth(200.), 40.));
        }];
        
    }
    
}

/**
 *  使用正则表达式提示用户只能输入字母和数字
 */
- (BOOL)isHaveNoneChineseWithText:(NSString *)text {
    
    NSString *patten = @"^[A-Za-z0-9]+$";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regular firstMatchInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length)];
    
    NSString *resultStr = [text substringWithRange:result.range];
    
    if (resultStr.length > 0) {
        return YES;
    }
    
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
