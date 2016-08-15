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

@interface PLLoginViewController ()<UITextFieldDelegate>
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
        PLChangePasswordVC *changePasswordVC = [[PLChangePasswordVC alloc] init];
        [self.navigationController pushViewController:changePasswordVC animated:YES];
        
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
