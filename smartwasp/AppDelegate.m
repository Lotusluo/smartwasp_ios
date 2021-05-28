//
//  AppDelegate.m
//  smartwasp
//
//  Created by luotao on 2021/4/8.
//

#import "AppDelegate.h"
#import "AppDelegate+Global.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import "CodingUtil.h"
#import "ConfigDAO.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "Device.h"

//定义小黄蜂appid
#define APPID @"28e49106-5d37-45fd-8ac8-c8d1f21356f5"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[IFLYOSSDK shareInstance] initAppId:APPID schema:@"smartwasp" loginType:DEFAULT];
    [[IFLYOSSDK shareInstance] setDebugModel:NO];
//    NSLog(@"屏幕大小:%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    //恢复用户数据
    NSString *usrValue = [[ConfigDAO sharedInstance] findByKey:@"usr"];
    if(usrValue){
        NSData *usrData = [CodingUtil dataFromHexString:usrValue];
        self.user = [NSKeyedUnarchiver unarchiveObjectWithData:usrData];
    }
    self.window =[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if(self.user){
        [self requestBindDevices];
        [self toMain];
    }else{
        [self toLogin];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

//复写当前设备选择方法
- (void) setCurDevice:(Device *)curDevice{
    _curDevice = curDevice;
    //通知刷新当前选择的设备
    NSLog(@"当前选择的设备:%@",curDevice.alias);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"devSetNotification" object:nil userInfo:nil];
}


//跳转登陆页面
- (void) toLogin{
    LoginViewController *loginVc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:loginVc];
    [navVc setNavigationBarHidden:YES animated:YES];
    navVc.navigationBar.topItem.title = @"";
    self.window.rootViewController = navVc;
}

//设置主界面
- (void) toMain{
    MainViewController *tabVc =[[MainViewController alloc] init];
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:tabVc];
    //默认隐藏导航条
    [navVc setNavigationBarHidden:YES animated:YES];
    navVc.navigationBar.topItem.title = @"";
    self.window.rootViewController = navVc;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
