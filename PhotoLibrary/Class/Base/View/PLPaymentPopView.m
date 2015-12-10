//
//  PLPaymentPopView.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPaymentPopView.h"

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
@end

@implementation PLPaymentPopView (Size)

- (CGSize)payButtonSize {
    return CGSizeMake(self.imageSize.width * 633. / 695., self.imageSize.height * 118. / 813.);
}

- (CGSize)backButtonSize {
    return CGSizeMake(self.imageSize.width * 81. / 695. + kBackButtonInsets * 2,
                      self.imageSize.height * 80. / 813. + kBackButtonInsets * 2);
}

- (CGSize)imageSize {
    const CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width * 0.9;
    return CGSizeMake(imageWidth, imageWidth*813./695.);
}

- (CGSize)contentSize {
    return self.imageSize;
}

- (CGRect)priceRect {
    return CGRectMake(self.imageSize.width * 0.18,
                      self.imageSize.height * 0.355,
                      self.imageSize.width * 0.1,
                      self.imageSize.height * 0.08);
}

- (CGPoint)alipayButtonOrigin {
    return CGPointMake(self.imageSize.width * 0.05, self.imageSize.height * 0.57);
}

- (CGPoint)wechatPayButtonOrigin {
    return CGPointMake(self.alipayButtonOrigin.x, self.imageSize.height * 0.74);
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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 3;

        _backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:_backgroundImageView];
        {
            [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self);
                make.bottom.equalTo(self).offset(-18);
            }];
        }
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.tag = kRegisteringDetailLabelTag;
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont boldSystemFontOfSize:20.];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.adjustsFontSizeToFitWidth = YES;
        _priceLabel = priceLabel;
        [self addSubview:priceLabel];
        {
            [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(self.priceRect.origin.x);
                make.top.equalTo(self).offset(self.priceRect.origin.y);
                make.size.mas_equalTo(self.priceRect.size);
            }];
        }
        
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
        
//        UIButton *upPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [upPayButton setImage:[UIImage imageNamed:@"uppay_normal"] forState:UIControlStateNormal];
//        [upPayButton setImage:[UIImage imageNamed:@"uppay_highlight"] forState:UIControlStateHighlighted];
//        [upPayButton addTarget:self action:@selector(onUPPay) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:upPayButton];
//        {
//            [upPayButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self).offset(self.upPayButtonOrigin.x);
//                make.top.equalTo(self).offset(self.upPayButtonOrigin.y);
//                make.size.mas_equalTo(self.payButtonSize);
//            }];
//        }
        
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

- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

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

- (void)onAlipay {
    if (self.paymentAction) {
        self.paymentAction(PLPaymentTypeAlipay);
    }
}

- (void)onWeChatPay {
    if (self.paymentAction) {
        self.paymentAction(PLPaymentTypeWeChatPay);
    }
}

//- (void)onUPPay {
//    if (self.paymentAction) {
//        self.paymentAction(PLPaymentTypeUPPay);
//    }
//}

- (void)onBack {
    if (self.backAction) {
        self.backAction();
    }
}
@end
