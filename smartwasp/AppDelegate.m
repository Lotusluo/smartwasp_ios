//
//  AppDelegate.m
//  smartwasp
//
//  Created by luotao on 2021/4/8.
//

#import "AppDelegate.h"
#import "AppDelegate+Global.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import <iflyosPushService/IFLYOSPushService.h>
#import <iflyosPushService/IFLYOSPushServiceProtocol.h>
#import "IFLYOSSDK.h"
#import "CodingUtil.h"
#import "ConfigDAO.h"
#import "DeviceBean.h"
#import "GSMonitorKeyboard.h"
#import "MusicStateBean.h"
#import "NSObject+YYModel.h"

//定义小黄蜂appid
#define APPID @"28e49106-5d37-45fd-8ac8-c8d1f21356f5"

//是否需要刷新绑定的设备的详细信息
BOOL NEED_REFRESH_DEVICES_DETAIL = YES;

@interface AppDelegate ()<IFLYOSPushServiceProtocol>

//媒体状态订阅服务
@property (nonatomic,strong) IFLYOSPushService *mediaStatePushService;


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[IFLYOSSDK shareInstance] initAppId:APPID schema:@"smartwasp" loginType:DEFAULT];
    [[IFLYOSSDK shareInstance] setDebugModel:NO];
    [[GSMonitorKeyboard sharedMonitorMethod] run];
    NSLog(@"屏幕大小:%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
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
- (void)setCurDevice:(DeviceBean *)curDevice{
    if(_curDevice && [_curDevice isEqual:curDevice])
        return;
    _curDevice = curDevice;
    //通知刷新当前选择的设备
    NSLog(@"当前选择的设备:%@",curDevice.alias);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"devSetNotification" object:nil userInfo:nil];
    //获取当前设备媒体状态并进行订阅
    [[IFLYOSSDK shareInstance] getMusicControlState:curDevice.device_id statusCode:^(NSInteger code) {
        if(code != 200){
            NSLog(@"获取设备媒体状态失败");
        }
    } requestSuccess:^(id _Nonnull data) {
        MusicStateBean *musicStateBean = [MusicStateBean yy_modelWithJSON:data];
        StatusBean<MusicStateBean*> *statusBean = StatusBean.new;
        statusBean.data = musicStateBean;
        self.mediaStatus = statusBean;
    } requestFail:^(id _Nonnull data) {
        NSLog(@"获取设备媒体状态失败");
    }];
    if(self.mediaStatePushService){
        [self.mediaStatePushService close];
        self.mediaStatePushService = nil;
    }
    //开始订阅媒体状态
    NSString *token = [IFLYOSSDK shareInstance].getToken;
    if (token){
        self.mediaStatePushService = [IFLYOSPushService createSocket:token command:@"connect" fromType:@"ALIAS" deviceId:curDevice.device_id];
        self.mediaStatePushService.delegate = self;
        [self.mediaStatePushService open];
    }
}

//复写当前设备媒体状态
-(void)setMediaStatus:(StatusBean<MusicStateBean *> *)mediaStatus{
    _mediaStatus = mediaStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mediaSetNotification" object:nil userInfo:nil];
}

#pragma mark --IFLYOSPushServiceProtocol
/**
 * socket连接成功
 */
-(void) onSockectOpenSuccess:(IFLYOSPushService *) socket{
    NSLog(@"媒体状态监听打开成功");
}

/**
 * socket连接失败
 * error:失败原因
*/
-(void) onSockect:(IFLYOSPushService *) socket error:(NSError *) error{
    NSLog(@"媒体状态监听打开失败：%@",error);
}
/**
 * socket 主动关闭连接回调（关闭成功后，清理socket相关东西）
 * code:关闭代码
 * reason:关闭原因
 * wasClean:是否清除
*/
-(void) onSockect:(IFLYOSPushService *) socket didCloseWithCode:(NSInteger) code reason:(NSString *) reason wasClean:(BOOL)wasClean{
    NSLog(@"媒体状态监听已关闭：%@",reason);
    
}

/**
 * 收到的信息
 * receiveMessage : 回调信息
 */
-(void) onSockect:(IFLYOSPushService *) socket receiveMessage:(id) receiveMessage{
    NSLog(@"onSockect:");
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
