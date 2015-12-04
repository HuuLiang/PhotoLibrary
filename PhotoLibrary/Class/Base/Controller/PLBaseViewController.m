//
//  PLBaseViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLBaseViewController.h"
#import "PLPaymentPopView.h"
#import "AlipayManager.h"
#import "WeChatPayManager.h"
#import "PLSystemConfigModel.h"
#import "PLAppDelegate.h"
#import "Order.h"
#import "PLProgram.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

@interface PLBaseViewController ()
//- (UIViewController *)playerVCWithVideo:(PLVideo *)video;
@end

@implementation PLBaseViewController

//- (UIViewController *)playerVCWithVideo:(PLVideo *)video {
//    UIViewController *retVC;
//    if (NSClassFromString(@"AVPlayerViewController")) {
//        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
//        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:video.videoUrl]];
//        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
//                          withOptions:AspectPositionAfter
//                           usingBlock:^(id<AspectInfo> aspectInfo){
//                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
//                               [thisPlayerVC.player play];
//                           } error:nil];
//        
//        retVC = playerVC;
//    } else {
//        retVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoUrl]];
//    }
//    
//    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
//        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
//        [[aspectInfo originalInvocation] setReturnValue:&mask];
//    } error:nil];
//    
//    [retVC aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
//        BOOL rotate = YES;
//        [[aspectInfo originalInvocation] setReturnValue:&rotate];
//    } error:nil];
//    return retVC;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
#ifdef EnableBaiduMobAd
    if (_bottomAdBanner) {
        CGRect newFrame = CGRectMake(0, self.view.bounds.size.height-self.adBannerHeight, self.view.bounds.size.width, self.adBannerHeight);
        if (!CGRectEqualToRect(newFrame, self.adView.frame)) {
            if ([self.view.subviews containsObject:self.adView]) {
                [self.adView removeFromSuperview];
                self.adView = nil;
            }
        }
        
        if (![self.view.subviews containsObject:self.adView]) {
            [self.view addSubview:self.adView];
        }
    }
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)switchToPlayProgram:(PLProgram *)program {
    if (![PLUtil isPaid]) {
        [self payForProgram:program shouldPopView:YES withCompletionHandler:nil];
    } else if (program.type.unsignedIntegerValue == PLProgramTypeVideo) {
//        UIViewController *videoPlayVC = [self playerVCWithVideo:program];
//        videoPlayVC.hidesBottomBarWhenPushed = YES;
//        //videoPlayVC.evaluateThumbnail = YES;
//        [self presentViewController:videoPlayVC animated:YES completion:nil];
    }
}

- (void)payForProgram:(PLProgram *)program
        shouldPopView:(BOOL)popped
withCompletionHandler:(void (^)(BOOL success))handler {
    [self fetchPayPriceWithCompletionHandler:^(NSNumber *payPrice) {
        if (!payPrice) {
            if (handler) {
                handler(NO);
            }
            return ;
        }
        
#ifdef DEBUG
        double price = 0.01;
#else
        double price = payPrice.doubleValue;
#endif
        if (popped) {
            PLPaymentPopView *paymentPopView = [PLPaymentPopView sharedInstance];
            paymentPopView.showPrice = price;
            
            @weakify(paymentPopView);
            paymentPopView.action = ^(PLPaymentType paymentType){
                [self payForProgram:program price:price paymentType:paymentType withCompletionHandler:^(NSUInteger result) {
                    @strongify(paymentPopView);
                    if (result == PAYRESULT_SUCCESS) {
                        [paymentPopView hide];
                        [[PLHudManager manager] showHudWithText:@"支付成功"];
                    }
                    if (handler) {
                        handler(result == PAYRESULT_SUCCESS);
                    }
                }];
            };
            [paymentPopView showInView:self.view.window];
        } else {
            [self payForProgram:program price:price paymentType:PLPaymentTypeAlipay withCompletionHandler:^(NSUInteger result) {
                if (handler) {
                    handler(result == PAYRESULT_SUCCESS);
                }
            }];
        }
    }];
}

- (void)onPaidNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *orderNo = userInfo[kPaidNotificationOrderNoKey];
    NSString *price = userInfo[kPaidNotificationPriceKey];
    
    [PLUtil setPaidPendingWithOrder:@[orderNo,price,@"",@"",@""]];
    [[PLPaymentPopView sharedInstance] hide];
    
    [self onPaymentCallbackWithOrderId:orderNo
                                 price:price
                                result:PAYRESULT_SUCCESS
                          forProgramId:@""
                           programType:@""
                          payPointType:@""
                           paymentType:PLPaymentTypeAlipay];
    
}

- (void)fetchPayPriceWithCompletionHandler:(void (^)(NSNumber *payPrice))handler {
    PLSystemConfigModel *systemConfigModel = [PLSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        if (handler) {
            handler (success ? @(systemConfigModel.payAmount) : nil);
        }
    }];
}

- (void)payForProgram:(PLProgram *)program
                price:(double)price
          paymentType:(PLPaymentType)paymentType
withCompletionHandler:(void (^)(NSUInteger result))handler {
    @weakify(self);
    NSString *channelNo = [PLConfig sharedConfig].channelNo;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    [PLUtil setPayingOrderWithOrderNo:orderNo paymentType:paymentType];
    
    void (^PayResultBack)(PAYRESULT result) = ^(PAYRESULT result) {
        @strongify(self);
        
        if (result == PAYRESULT_SUCCESS) {
            [PLUtil setPaidPendingWithOrder:@[orderNo,
                                              @(price).stringValue,
                                              program.programId.stringValue ?: @"",
                                              program.type.stringValue ?: @"",
                                              //program.payPointType.stringValue ?:
                                              @""]];
            
        } else if (result == PAYRESULT_FAIL) {
            [[PLHudManager manager] showHudWithText:@"支付失败"];
        } else if (result == PAYRESULT_ABANDON) {
            [[PLHudManager manager] showHudWithText:@"支付取消"];
        }
        
        if (handler) {
            handler(result);
        }
        
        [self onPaymentCallbackWithOrderId:orderNo
                                     price:@(price).stringValue
                                    result:result
                              forProgramId:program.programId.stringValue ?: @""
                               programType:program.type.stringValue ?: @""
                              payPointType:@""//program.payPointType.stringValue ?: @""
                               paymentType:paymentType];
    };
    
    if (paymentType == PLPaymentTypeAlipay) {
        [[AlipayManager shareInstance] startAlipay:orderNo
                                             price:@(price).stringValue
                                        withResult:^(PAYRESULT result, Order *order) {
                                            PayResultBack(result);
                                        }];
    } else if (paymentType == PLPaymentTypeWeChatPay) {
        [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo
                                                               price:price
                                                   completionHandler:^(PAYRESULT payResult) {
                                                       PayResultBack(payResult);
                                                   }];
    }
    
}

- (void)onPaymentCallbackWithOrderId:(NSString *)orderId
                               price:(NSString *)price
                              result:(PAYRESULT)result
                        forProgramId:(NSString *)programId
                         programType:(NSString *)programType
                        payPointType:(NSString *)payPointType
                         paymentType:(PLPaymentType)paymentType {
    PLAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate paidWithOrderId:orderId
                           price:price
                          result:result
                    forProgramId:programId
                     programType:programType
                    payPointType:payPointType
                     paymentType:paymentType];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
