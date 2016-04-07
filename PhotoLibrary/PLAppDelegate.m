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
/**新添加的免费控制器*/
#import "PLFreeViewController.h"
#import "PLSettingViewController.h"
#import "PLErrorHandler.h"
#import "PLActivateModel.h"
#import "PLPaymentModel.h"
#import "PLUserAccessModel.h"
#import "PLSystemConfigModel.h"
#import "WXApi.h"
#import "WeChatPayManager.h"
#import "PLWeChatPayQueryOrderRequest.h"
#import "PLPaymentViewController.h"
#import "KbPaymentManager.h"
@interface PLAppDelegate ()<WXApiDelegate>

@property (nonatomic,retain) PLWeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;

@end

@implementation PLAppDelegate

DefineLazyPropertyInitialization(PLWeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

#pragma mark - 初始化window
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
    /**免费的控制器*/
    PLFreeViewController *freeVC = [[PLFreeViewController alloc] init];
    freeVC.title = @"免费";
    freeVC.bottomAdBanner = YES;
    UINavigationController *freeNav   = [[UINavigationController alloc] initWithRootViewController:freeVC];
    freeNav.tabBarItem                = [[UITabBarItem alloc] initWithTitle:freeVC.title
                                                                       image:[UIImage imageNamed:@"tab_icon"]
                                                               selectedImage:[UIImage imageNamed:@"tab_icon_press"]];
    
    
    PLSettingViewController *settingVC = [[PLSettingViewController alloc] init];
    settingVC.title = @"设置";
    
    settingVC.bottomAdBanner = YES;

    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    settingNav.tabBarItem              = [[UITabBarItem alloc] initWithTitle:settingVC.title
                                                                    image:[UIImage imageNamed:@"normal_setting_bar"]
                                                            selectedImage:[UIImage imageNamed:@"selected_setting_bar"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers     = @[photoNav,videoNav,freeNav,settingNav];
    tabBarController.tabBar.translucent  = NO;
    //设置tabbar选中的渲染效果
    tabBarController.tabBar.tintColor = [UIColor blackColor];
    _window.rootViewController           = tabBarController;
    return _window;
}

#pragma mark - 设置控制器共有的规格
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

#pragma mark - Appdelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //不管是爱贝支付还是微信支付都在这个里面初始化配置
    [[KbPaymentManager sharedManager] setup];

//    [WXApi registerApp:[PLConfig sharedConfig].weChatPayAppId];
    
    //初始化错误处理（实际就是注册通知）
    [[PLErrorHandler sharedHandler] initialize];
    
    //程序一加载就开启友盟访问统计
    [PLStatistics start];
    
    //设置控制器通用的风格
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
    //提交订单
    [[PLPaymentModel sharedModel] startRetryingToCommitUnprocessedOrders];
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
       [self checkPayment];
}


//当用户通过其它应用启动本应用时，会回调这个方法，url参数是其它应用调用openURL:方法时传过来的。支付完成之后回到本应用
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[KbPaymentManager sharedManager] handleOpenURL:url];
//    [WXApi handleOpenURL:url delegate:self];
    return YES;
    
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
  [[KbPaymentManager sharedManager] handleOpenURL:url];
    return YES;
}
#pragma mark - 检查是否支付过
-(void)checkPayment{
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
