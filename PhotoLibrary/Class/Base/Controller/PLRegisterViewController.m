//
//  PLRegisterViewController.m
//  PhotoLibrary
//
//  Created by ylz on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLRegisterViewController.h"
#import "PLTextField.h"

@interface PLRegisterViewController ()<UITextFieldDelegate>
{
    PLTextField *_accountField;
    PLTextField *_passwordField;
    PLTextField *_nextPasswordField;
    UIButton *_registBtn;
}
@end

@implementation PLRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStylePlain target:self action:@selector(popToLoginView)];
    
    [self setUpUI];
}

- (void)popToLoginView {
    [self.navigationController popViewControllerAnimated:YES];
    
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
    _nextPasswordField = [[PLTextField alloc] initWithPlaceholder:@"密码" leftImage:@"popup_menu_marked"];
    _nextPasswordField.delegate = self;
    _nextPasswordField.font = [UIFont systemFontOfSize:KWidth(18.)];
    [self.view addSubview:_nextPasswordField];
    {
        [_nextPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_accountField);
            make.top.mas_equalTo(_passwordField.mas_bottom).mas_offset(KWidth(5.));
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.75, KWidth(50.)));
        }];
    }
    
    UIView *sepView3 = [[UIView alloc] init];
    sepView3.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [self.view addSubview:sepView3];
    {
        [sepView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_accountField);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.85, KWidth(1.)));
            make.top.mas_equalTo(_nextPasswordField.mas_bottom).mas_offset(-1.);
            
        }];
    }
    
    _registBtn = [[UIButton alloc] init];
    _registBtn.backgroundColor = [UIColor colorWithHexString:@"#ff680d"];
    [_registBtn setTitle:@"注册账号" forState:UIControlStateNormal];
    [_registBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    _registBtn.titleLabel.font = [UIFont systemFontOfSize:KWidth(18.)];
    _registBtn.layer.cornerRadius = 5.;
    _registBtn.clipsToBounds = YES;
    
    [_registBtn bk_addEventHandler:^(id sender) {
        DLog(@"%@---密码:%@",_accountField.text,_passwordField.text);
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_registBtn];
    {
        [_registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_accountField);
            make.top.mas_equalTo(_nextPasswordField.mas_bottom).mas_offset(KWidth(15.));
            make.size.mas_equalTo(CGSizeMake(kScreenWidth*0.75, KWidth(45.)));
        }];
    }
    
    UIButton *loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"已有账号请登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:KWidth(16.)];
    [loginBtn setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateHighlighted];
    loginBtn.backgroundColor = [UIColor clearColor];
    [loginBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self popToLoginView];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginBtn];
    {
        [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_registBtn.mas_bottom);
            make.right.mas_equalTo(_registBtn).mas_offset(KWidth(-2.5));
        }];
        
    }
    
    [self.view bk_whenTapped:^{
        [_accountField resignFirstResponder];
        [_passwordField resignFirstResponder];
    }];
    
}


@end
