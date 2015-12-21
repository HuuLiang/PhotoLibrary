//
//  PLAppDelegate.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLAppDelegate.h"
#import "PLPhotoViewController.h"
#import "PLVideoViewController.h"
#import "PLSettingViewController.h"
#import "PLErrorHandler.h"
#import "PLActivateModel.h"
#import "PLPaymentModel.h"
#import "PLUserAccessModel.h"
#import "PLSystemConfigModel.h"
#import "IpaynowPluginApi.h"
#import "WXApi.h"
#import "WeChatPayManager.h"
#import "PLWeChatPayQueryOrderRequest.h"
#import "PLPaymentViewController.h"

@interface PLAppDelegate ()<WXApiDelegate>

@property (nonatomic,retain) PLWeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;

@end

@implementation PLAppDelegate

DefineLazyPropertyInitialization(PLWeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

- (UIWindow *)window {
    if (_window) {
        return _window;
    }
    
    _window                              = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor              = [UIColor whiteColor];
    
    PLPhotoViewController *photoVC       = [[PLPhotoViewController alloc] init];
    photoVC.title = @"图库";
    photoVC.bottomAdBanner = YES;
    UINavigationController *photoNav     = [[UINavigationController alloc] initWithRootViewController:photoVC];
    photoNav.tabBarItem                  = [[UITabBarItem alloc] initWithTitle:photoVC.title
                                                                         image:[UIImage imageNamed:@"normal_photo_bar"]
                                                                 selectedImage:[UIImage imageNamed:@"selected_photo_bar"]];
    
    PLVideoViewController *videoVC     = [[PLVideoViewController alloc] init];
    videoVC.title = @"视频";
    videoVC.bottomAdBanner = YES;
    UINavigationController *videoNav   = [[UINavigationController alloc] initWithRootViewController:videoVC];
    videoNav.tabBarItem                = [[UITabBarItem alloc] initWithTitle:videoVC.title
                                                                         image:[UIImage imageNamed:@"normal_video_bar"]
                                                                 selectedImage:[UIImage imageNamed:@"selected_video_bar"]];
    
    PLSettingViewController *settingVC = [[PLSettingViewController alloc] init];
    settingVC.title = @"设置";
    settingVC.bottomAdBanner = YES;
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    settingNav.tabBarItem              = [[UITabBarItem alloc] initWithTitle:settingVC.title
                                                                    image:[UIImage imageNamed:@"normal_setting_bar"]
                                                            selectedImage:[UIImage imageNamed:@"selected_setting_bar"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers     = @[photoNav,videoNav,settingNav];
    tabBarController.tabBar.translucent  = NO;
    tabBarController.tabBar.tintColor = [UIColor blackColor];
    _window.rootViewController           = tabBarController;
    return _window;
}

- (void)setupCommonStyles {
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   thisVC.navigationController.navigationBar.translucent = NO;
                                   thisVC.navigationController.navigationBar.barStyle = UIBarStyleBlack;
                                   thisVC.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#99003b"];
                               } error:nil];
    
    [UINavigationController aspect_hookSelector:@selector(preferredStatusBarStyle)
                                    withOptions:AspectPositionInstead
                                     usingBlock:^(id<AspectInfo> aspectInfo){
                                         UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                         [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
                                     } error:nil];
    
    [UIViewController aspect_hookSelector:@selector(preferredStatusBarStyle)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                   [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
                               } error:nil];
    
    [UITabBarController aspect_hookSelector:@selector(shouldAutorotate)
                                withOptions:AspectPositionInstead
                                 usingBlock:^(id<AspectInfo> aspectInfo){
                                     UITabBarController *thisTabBarVC = [aspectInfo instance];
                                     UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                     
                                     BOOL autoRotate = NO;
                                     if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                         autoRotate = [((UINavigationController *)selectedVC).topViewController shouldAutorotate];
                                     } else {
                                         autoRotate = [selectedVC shouldAutorotate];
                                     }
                                     [[aspectInfo originalInvocation] setReturnValue:&autoRotate];
                                 } error:nil];
    
    [UITabBarController aspect_hookSelector:@selector(supportedInterfaceOrientations)
                                withOptions:AspectPositionInstead
                                 usingBlock:^(id<AspectInfo> aspectInfo){
                                     UITabBarController *thisTabBarVC = [aspectInfo instance];
                                     UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                     
                                     NSUInteger result = 0;
                                     if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                         result = [((UINavigationController *)selectedVC).topViewController supportedInterfaceOrientations];
                                     } else {
                                         result = [selectedVC supportedInterfaceOrientations];
                                     }
                                     [[aspectInfo originalInvocation] setReturnValue:&result];
                                 } error:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [WXApi registerApp:[PLConfig sharedConfig].weChatPayAppId];
    [[PLErrorHandler sharedHandler] initialize];
    [PLStatistics start];
    [self setupCommonStyles];
    [self.window makeKeyAndVisible];
    
    if (![PLUtil isRegistered]) {
        [[PLActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
            if (success) {
                [PLUtil setRegisteredWithUserId:userId];
                [[PLUserAccessModel sharedModel] requestUserAccess];
            }
        }];
    } else {
        [[PLUserAccessModel sharedModel] requestUserAccess];
    }
    
    [[PLPaymentModel sharedModel] processPendingOrder];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [IpaynowPluginApi willEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self checkPayment];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [IpaynowPluginApi application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}

-(void)checkPayment{
    if ([PLUtil PLisPaid]) {
        return;
    }
    NSArray<PLPaymentInfo *> *payingPaymentInfos = [PLUtil payingPaymentInfos];
    [payingPaymentInfos enumerateObjectsUsingBlock:^(PLPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PLPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
        if (paymentType == PLPaymentTypeWeChatPay) {
            [self.wechatPayOrderQueryRequest queryOrderWithNo:obj.orderId completionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    PLPaymentViewController *paymentVC = [PLPaymentViewController sharedPaymentVC];
                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
                }
            }];
        }
    }];
}

#pragma mark - WeChat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PAYRESULT payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = PAYRESULT_ABANDON;
        } else if (resp.errCode == WXSuccess) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}

@end
