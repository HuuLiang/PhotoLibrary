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
//- (UIViewController *)playerVCWithVideo:(PLVideo *)video;
@end

@implementation PLBaseViewController

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
    
    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
        [[aspectInfo originalInvocation] setReturnValue:&mask];
    } error:nil];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaymentNotification:) name:kPaymentNotificationName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)onPaymentNotification:(NSNotification *)notification {}

- (void)payForPayable:(id<PLPayable>)payable withCompletionHandler:(PLPaymentCompletionHandler)handler {
    if ([payable payableUsage] == PLPaymentForUnknown) {
        if (handler) {
            handler(NO);
        }
        return ;
    }
    
    if ([PLPaymentUtil isPaidForPayable:payable]) {
        if (handler) {
            handler(YES);
        }
        return ;
    }
    
    [[PLPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forPayable:payable withCompletionHandler:handler];
}

- (void)playVideo:(PLVideo *)video {
    if (video.type.unsignedIntegerValue == PLProgramTypeVideo) {
        UIViewController *videoPlayVC = [self playerVCWithVideo:video];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        //videoPlayVC.evaluateThumbnail = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
        
        [PLStatistics statViewVideo:video];
    }
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
