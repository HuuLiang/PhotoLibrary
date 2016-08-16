//
//  PLLoginViewController.m
//  PhotoLibrary
//
//  Created by ylz on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLLoginViewController.h"
#import "PLRegisterViewController.h"
#import "PLChangePasswordVC.h"
#import "PLTextField.h"
#import "PLActivateModel.h"
#import "PLAppDelegate.h"

@interface PLLoginViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    PLTextField *_accountField;
    PLTextField *_passwordField;
    
    UIButton *_loginBtn;
}

@end

@implementation PLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)setUpUI {
    @weakify(self);
    _accountField = [[PLTextField alloc] initWithPlaceholder:@"账号" leftImage:@"popup_menu_marked"];
    _accountField.delegate = self;
    _accountField.font = [UIFont systemFontOfSize:KWidth(18.)];
    [self.view addSubview:_accountField];
    {
        [_accountField mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(self.view);
            make.centerY.mas_equalTo(self.view).mas_offset(-KWidth(100.));
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.75, KWidth(50.)));
            
        }];
    }
    
    UIView *sepView1 = [[UIView alloc] init];
    sepView1.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [self.view addSubview:sepView1];
    {
        [sepView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            //        make.left.mas_equalTo(self.view).mas_offset(KWidth(15.));
            //        make.right.mas_equalTo(self.view).mas_offset(KWidth(-15.));
            make.centerX.mas_equalTo(_accountField);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.85, KWidth(1.)));
            make.top.mas_equalTo(_accountField.mas_bottom).mas_offset(-1.);
            
        }];
    }
    
    _passwordField = [[PLTextField alloc] initWithPlaceholder:@"密码" leftImage:@"popup_menu_marked"];
    _passwordField.delegate = self;
    _passwordField.secureTextEntry = YES;
    _passwordField.font = [UIFont systemFontOfSize:KWidth(18.)];
    [self.view addSubview:_passwordField];
    {
        [_passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_accountField);
            make.top.mas_equalTo(_accountField.mas_bottom).mas_offset(KWidth(5.));
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.75, KWidth(50.)));
        }];
    }
    
    UIView *sepView2 = [[UIView alloc] init];
    sepView2.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [self.view addSubview:sepView2];
    {
        [sepView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            //        make.left.mas_equalTo(self.view).mas_offset(KWidth(15.));
            //        make.right.mas_equalTo(self.view).mas_offset(KWidth(-15.));
            make.centerX.mas_equalTo(_accountField);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.85, KWidth(1.)));
            make.top.mas_equalTo(_passwordField.mas_bottom).mas_offset(-1.);
            
        }];
    }
    
    _loginBtn = [[UIButton alloc] init];
    _loginBtn.backgroundColor = [UIColor colorWithHexString:@"#ff680d"];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:KWidth(18.)];
    _loginBtn.layer.cornerRadius = 5.;
    _loginBtn.clipsToBounds = YES;
    
    [_loginBtn bk_addEventHandler:^(id sender) {
        DLog(@"%@---密码:%@",_accountField.text,_passwordField.text);
        
        
        if (_accountField.text.length >=4 && _passwordField.text.length >=6 &&_accountField.text.length<=12 && _passwordField.text.length<= 12 ) {
            
            
            if ([self isHaveNoneChineseWithText:_accountField.text] && [self isHaveNoneChineseWithText:_passwordField.text]) {
                
                [self.view pl_beginLoading];
                
                //需要先判断登录是否成功
                [[NSUserDefaults standardUserDefaults] setObject:_accountField.text forKey:kUserAccount];
                [[NSUserDefaults standardUserDefaults] setObject:_passwordField.text forKey:kUserPassword];
                [[NSUserDefaults standardUserDefaults ] setObject:@"yes" forKey:kUserLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if ([PLUtil isRegistered]) {
                    PLAppDelegate *app = (PLAppDelegate *)[UIApplication sharedApplication].delegate;
                    [app registAppId];
                }else{
                    
                    [[PLActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
                        [self.view pl_endLoading];
                        if (success) {
                            
                            [PLUtil setRegisteredWithUserId:userId];
                            PLAppDelegate *app = (PLAppDelegate *)[UIApplication sharedApplication].delegate;
                            [app registAppId];
                            
                        }else {
                            [[PLHudManager manager] showHudWithText:@"登录失败"];
                        }
                    }];
                }
                
            }else {
                [[PLHudManager manager] showHudWithText:@"只能输入字母和数字"];
            }
            
        } else {
            
            [[PLHudManager manager] showHudWithText:@"账号密码长度分别在4-12和6-12个字符之间"];
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginBtn];
    {
        [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_accountField);
            make.top.mas_equalTo(_passwordField.mas_bottom).mas_offset(KWidth(15.));
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.75, KWidth(45.)));
        }];
    }
    
    UIButton *changePasswordBtn = [[UIButton alloc] init];
    [changePasswordBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    changePasswordBtn.titleLabel.font = [UIFont systemFontOfSize:KWidth(16.)];
    [changePasswordBtn setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    [changePasswordBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateHighlighted];
    changePasswordBtn.backgroundColor = [UIColor clearColor];
    [changePasswordBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        //        PLChangePasswordVC *changePasswordVC = [[PLChangePasswordVC alloc] init];
        //        [self.navigationController pushViewController:changePasswordVC animated:YES];
        
        UIAlertView *aleterView = [[UIAlertView alloc] initWithTitle:@"联系客服" message:@"如果忘记密码请联系客服:QQ1243345345或电联" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打电话", nil];
        [aleterView show];
        
        
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changePasswordBtn];
    {
        [changePasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_loginBtn.mas_bottom);
            make.left.mas_equalTo(_loginBtn).mas_offset(KWidth(2.5));
        }];
        
    }
    
    
    UIButton *registBtn = [[UIButton alloc] init];
    [registBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    registBtn.titleLabel.font = [UIFont systemFontOfSize:KWidth(16.)];
    [registBtn setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    [registBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateHighlighted];
    registBtn.backgroundColor = [UIColor clearColor];
    
    [registBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        PLRegisterViewController *registVC = [[PLRegisterViewController alloc] init];
        [self.navigationController pushViewController:registVC animated:YES];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:registBtn];
    {
        [registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_loginBtn.mas_bottom);
            make.right.mas_equalTo(_loginBtn).mas_offset(KWidth(-2.5));
        }];
        
    }
    
    [self.view bk_whenTapped:^{
        [_accountField resignFirstResponder];
        [_passwordField resignFirstResponder];
    }];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:12432434435"]];
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
