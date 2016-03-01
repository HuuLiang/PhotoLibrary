//
//  PLPaymentPopView.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPaymentPopView.h"
/**标签的tag*/
static const NSUInteger kRegisteringDetailLabelTag = 1;
static const CGFloat kBackButtonInsets = 10;

@interface PLPaymentPopView ()
{
    UIImageView *_backgroundImageView;
    UILabel *_priceLabel;
}
@property (nonatomic,readonly) CGSize contentViewSize;
@property (nonatomic,readonly) CGSize imageSize;
@property (nonatomic,readonly) CGRect priceRect;

@property (nonatomic,readonly) CGSize payButtonSize;
@property (nonatomic,readonly) CGSize backButtonSize;
@property (nonatomic,readonly) CGPoint alipayButtonOrigin;
@property (nonatomic,readonly) CGPoint wechatPayButtonOrigin;
@property (nonatomic,readonly) CGPoint upPayButtonOrigin;
@end

@implementation PLPaymentPopView (Size)

/**支付按钮尺寸*/
- (CGSize)payButtonSize {
    return CGSizeMake(self.imageSize.width * 633. / 695., self.imageSize.height * 118. / 939.);
}
/**返回按钮尺寸*/
- (CGSize)backButtonSize {
    return CGSizeMake(self.imageSize.width * 81. / 695. + kBackButtonInsets * 2,
                      self.imageSize.height * 80. / 939. + kBackButtonInsets * 2);
}
/**图片尺寸*/
- (CGSize)imageSize {
    const CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width * 0.9;
    return CGSizeMake(imageWidth, imageWidth*939./695.);
}
/**容器的尺寸*/
- (CGSize)contentSize {
    return self.imageSize;
}
/**价格的frame*/
- (CGRect)priceRect {
    return CGRectMake(self.imageSize.width * 0.178,
                      self.imageSize.height * 0.313,
                      self.imageSize.width * 0.09,
                      self.imageSize.height * 0.06);
}
/**支付宝按钮的起点坐标*/
- (CGPoint)alipayButtonOrigin {
    return CGPointMake(self.imageSize.width * 0.05, self.imageSize.height * 0.535);
}
/**微信按钮的起点坐标*/
- (CGPoint)wechatPayButtonOrigin {
    return CGPointMake(self.alipayButtonOrigin.x, self.imageSize.height * 0.67);
}
/**银联支付按钮的起点坐标*/
- (CGPoint)upPayButtonOrigin {
    return CGPointMake(self.alipayButtonOrigin.x, 2 * self.wechatPayButtonOrigin.y - self.alipayButtonOrigin.y);
}
@end

@implementation PLPaymentPopView

+ (instancetype)sharedInstance {
    static PLPaymentPopView *_sharedPaymentPopView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPaymentPopView = [[PLPaymentPopView alloc] init];
    });
    return _sharedPaymentPopView;
}

- (void)setUsage:(PLPaymentUsage)usage {
    _usage = usage;
    
    NSDictionary *usageMap = @{@(PLPaymentForPhotoChannel):@"payment_channel",
                               @(PLPaymentForPhotoAlbum):@"payment_album",
                               @(PLPaymentForVideo):@"payment_video"};
    _backgroundImageView.image = [UIImage imageNamed:usageMap[@(usage)]];
    _priceLabel.textColor = usage == PLPaymentForPhotoChannel ? [UIColor yellowColor] :[UIColor redColor];
}

/**重写init方法*/
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 3;
        /**背景图片*/
        _backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:_backgroundImageView];
        {
            [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self);
                make.bottom.equalTo(self).offset(-18);
            }];
        }
        
        /**价格label*/
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.tag = kRegisteringDetailLabelTag;
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont boldSystemFontOfSize:20.];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.adjustsFontSizeToFitWidth = YES;//自动根据label的宽度调整字体大小
        _priceLabel = priceLabel;
        [self addSubview:priceLabel];
        {
            [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(self.priceRect.origin.x);
                make.top.equalTo(self).offset(self.priceRect.origin.y);
                make.size.mas_equalTo(self.priceRect.size);
            }];
        }
        /**支付宝支付button*/
        UIButton *alipayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [alipayButton setImage:[UIImage imageNamed:@"alipay_normal"] forState:UIControlStateNormal];
        [alipayButton setImage:[UIImage imageNamed:@"alipay_highlight"] forState:UIControlStateHighlighted];
        [alipayButton addTarget:self action:@selector(onAlipay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:alipayButton];
        {
            [alipayButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(self.alipayButtonOrigin.x);
                make.top.equalTo(self).offset(self.alipayButtonOrigin.y);
                make.size.mas_equalTo(self.payButtonSize);
            }];
        }
        /**微信支付button*/
        UIButton *wechatPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [wechatPayButton setImage:[UIImage imageNamed:@"wechatpay_normal"] forState:UIControlStateNormal];
        [wechatPayButton setImage:[UIImage imageNamed:@"wechatpay_highlight"] forState:UIControlStateHighlighted];
        [wechatPayButton addTarget:self action:@selector(onWeChatPay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:wechatPayButton];
        {
            [wechatPayButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(self.wechatPayButtonOrigin.x);
                make.top.equalTo(self).offset(self.wechatPayButtonOrigin.y);
                make.size.mas_equalTo(self.payButtonSize);
            }];
        }
        /**银联支付button*/
        UIButton *upPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [upPayButton setImage:[UIImage imageNamed:@"uppay_normal"] forState:UIControlStateNormal];
        [upPayButton setImage:[UIImage imageNamed:@"uppay_highlight"] forState:UIControlStateHighlighted];
        [upPayButton addTarget:self action:@selector(onUPPay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:upPayButton];
        {
            [upPayButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(self.upPayButtonOrigin.x);
                make.top.equalTo(self).offset(self.upPayButtonOrigin.y);
                make.size.mas_equalTo(self.payButtonSize);
            }];
        }
        /**返回button*/
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"payment_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
        backButton.contentEdgeInsets = UIEdgeInsetsMake(kBackButtonInsets, kBackButtonInsets, kBackButtonInsets, kBackButtonInsets);
        [self addSubview:backButton];
        {
            [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.equalTo(self).offset(5);
                make.size.mas_equalTo(self.backButtonSize);
            }];
        }
    }
    return self;
}
/**显示在哪个视图上*/
- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}
/**隐藏*/
- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
/**设置显示价格*/
- (void)setShowPrice:(NSNumber *)showPrice {
    _showPrice = showPrice;
    
    UILabel *detailLabel = (UILabel *)[self viewWithTag:kRegisteringDetailLabelTag];
    if (showPrice) {
        BOOL showInteger = (NSUInteger)(showPrice.doubleValue * 100) % 100 == 0;
        detailLabel.text = showInteger ? [NSString stringWithFormat:@"%ld", showPrice.unsignedIntegerValue] : [NSString stringWithFormat:@"%.2f", showPrice.doubleValue];
    } else {
        detailLabel.text = @"???";
    }
}
/**支付宝支付*/
- (void)onAlipay {
    if (self.paymentAction) {
        self.paymentAction(PLPaymentTypeAlipay);
    }
}
/**微信支付*/
- (void)onWeChatPay {
    if (self.paymentAction) {
        self.paymentAction(PLPaymentTypeWeChatPay);
    }
}
/**银联支付*/
- (void)onUPPay {
    if (self.paymentAction) {
        self.paymentAction(PLPaymentTypeUPPay);
    }
}
/**返回*/
- (void)onBack {
    if (self.backAction) {
        self.backAction();
    }
}
@end
