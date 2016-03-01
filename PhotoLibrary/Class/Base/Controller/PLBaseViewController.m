//
//  PLBaseViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLBaseViewController.h"
#import "PLPaymentPopView.h"
#import "PLSystemConfigModel.h"
#import "PLAppDelegate.h"
#import "PLProgram.h"
#import "PLVideo.h"
#import "PLPaymentModel.h"
#import "PLPaymentViewController.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

@interface PLBaseViewController ()
@end


@implementation PLBaseViewController

/**返回播放视频的控制器*/
- (UIViewController *)playerVCWithVideo:(PLVideo *)video {
    
    UIViewController *retVC;
    
    if (NSClassFromString(@"AVPlayerViewController")) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:video.videoUrl]];
        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
                          withOptions:AspectPositionAfter
                           usingBlock:^(id<AspectInfo> aspectInfo){
                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
                               [thisPlayerVC.player play];
                           } error:nil];
        
        retVC = playerVC;
    } else {
        retVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoUrl]];
    }
    
    //设置屏幕方向
    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
        [[aspectInfo originalInvocation] setReturnValue:&mask];
    } error:nil];
    //设置屏幕是否可以旋转
    [retVC aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        BOOL rotate = YES;
        [[aspectInfo originalInvocation] setReturnValue:&rotate];
    } error:nil];
    return retVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
    /**注册支付通知*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaymentNotification:) name:kPaymentNotificationName object:nil];
}
/**移除通知*/
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**接收到支付通知*/
- (void)onPaymentNotification:(NSNotification *)notification {}

- (void)payForPayable:(id<PLPayable>)payable withCompletionHandler:(PLPaymentCompletionHandler)handler {
    if ([payable payableUsage] == PLPaymentForUnknown) {
        if (handler) {//支付失败，回调为NO
            handler(NO);
        }
        return ;
    }
    
    if ([PLPaymentUtil isPaidForPayable:payable]) {//PLPaymentUtil查看，保存支付纪录的类
        if (handler) {//支付成功,回调为YES
            handler(YES);
        }
        return ;
    }
    //如果没有支付，弹出支付界面
    [[PLPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forPayable:payable withCompletionHandler:handler];
//    handler(YES);
}

/**开始播放视频*/
- (void)playVideo:(PLVideo *)video {
    if (video.type.unsignedIntegerValue == PLProgramTypeVideo) {
        UIViewController *videoPlayVC = [self playerVCWithVideo:video];
        videoPlayVC.hidesBottomBarWhenPushed = YES;//有这一句返回时候回自动出来
        //videoPlayVC.evaluateThumbnail = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
        //
        [PLStatistics statViewVideo:video];
    }
}

/**是否自动旋转*/
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
