//
//  PLVipCell.m
//  PhotoLibrary
//
//  Created by Liang on 16/7/1.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLVipCell.h"

@interface PLVipCell ()
{
    UIImageView *_imgV;
    UILabel *_titleLabel;
    UILabel *_priceLabel;
    UIButton *_payBtn;
}
@end

@implementation PLVipCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _imgV = [[UIImageView alloc] init];
        [self addSubview:_imgV];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:kScreenWidth*34/750.];
        [self addSubview:_titleLabel];
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#ff680d"];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.font = [UIFont systemFontOfSize:kScreenWidth*28/750.];
        [self addSubview:_priceLabel];
        
        _payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_payBtn setTitle:@"开通" forState:UIControlStateNormal];
        _payBtn.layer.cornerRadius = 5;
        _payBtn.layer.masksToBounds = YES;
        _payBtn.titleLabel.font = [UIFont fontWithName:@"NotoSanHans" size:kScreenWidth *26/750.];
//        _payBtn.backgroundColor = [UIColor colorWithHexString:@"#ff680d"];
        [_payBtn setBackgroundImage:[UIImage imageNamed:@"settingbtn"] forState:UIControlStateNormal];
        [_payBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_payBtn bk_addEventHandler:^(id sender) {
            if (self.payBtnblock) {
                self.payBtnblock();
            }
            
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_payBtn];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(kScreenWidth*20/750.);
                make.centerY.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kScreenWidth*120/750., kScreenWidth*120/750));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgV.mas_right).offset(kScreenWidth*15/750.);
                make.centerY.equalTo(self);
                make.height.mas_equalTo(20);
            }];
            
            [_payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-kScreenWidth*15/750.);
                make.centerY.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kScreenWidth*152/750., kScreenWidth*68/750.));
            }];
            
            [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_payBtn.mas_left).offset(-15);
                make.centerY.equalTo(self);
                make.height.mas_equalTo(40);
            }];
        }
    }
    return self;
}
-(void)setBgImg:(NSString *)bgImg {
    _imgV.image = [UIImage imageNamed:bgImg];
    if ([bgImg isEqualToString:@"setting_photo_icon"]) {
        _titleLabel.text = @"图集VIP";
        _payBtn.enabled = [PLUtil isPictureVip] ? NO : YES;
    } else {
        _titleLabel.text = @"视频VIP";
         _payBtn.enabled = [PLUtil isVideoVip] ? NO : YES;
    }
}

- (void)setPrice:(NSString *)price {
    _priceLabel.text = price;
}

- (void)setPayBtnStr:(NSString *)payBtnStr {
    _payBtnStr = payBtnStr;
    
    [_payBtn setTitle:payBtnStr forState:UIControlStateNormal];
}



@end
