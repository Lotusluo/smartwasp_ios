//
//  AppDelegate.m
//  smartwasp
//
//  Created by luotao on 2021/4/8.
//

#import "AppDelegate.h"
#import "AppDelegate+Global.h"
#import "CodingUtil.h"
#import "GSMonitorKeyboard.h"



//定义小黄蜂appid
#define APPID @"28e49106-5d37-45fd-8ac8-c8d1f21356f5"


BOOL NEED_MAIN_REFRESH_DEVICES = YES;

@interface AppDelegate ()<IFLYOSPushServiceProtocol>{
    NSInteger mediaErrTimez;
    NSInteger deviceErrTimez;
}

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
    [NSThread sleepForTimeInterval:3];
    self.window =[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if(self.user){
        [self toMain];
    }else{
        [self toLogin];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

//设置设备列表
-(void)setDevices:(NSArray<DeviceBean *> *)devices{
    _devices = devices;
    if(!self.devices || self.devices.count < 1){
        self.curDevice = nil;
    }else{
        //上一次选择的设备
        NSString *devValue = [[ConfigDAO sharedInstance] findByKey:@"dev_selected"];
        if(devValue && ![devValue isEqualToString:@""]){
            for(DeviceBean *devBean in self.devices){
                if([devBean.device_id isEqualToString:devValue]){
                    self.curDevice = devBean;
                    break;
                }
            }
        }
        if(!self.curDevice){
            //默认选择第一个
            self.curDevice = devices[0];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"devsSetNotification" object:nil userInfo:nil];
}

//设置当前设备选择方法
-(void)setCurDevice:(DeviceBean *)curDevice{
    if(_curDevice && curDevice && [_curDevice isEqual:curDevice]){
        //设备未更改则返回
        return;
    }
    //取消订阅设备状态
    [self disSubscribeMediaStatus];
    _curDevice = curDevice;
    self.mediaStatus = nil;
    //通知刷新当前选择的设备
    if(self.curDevice){
        NSLog(@"当前选择的设备:%@",curDevice.alias);
        [[ConfigDAO sharedInstance] setKey:@"dev_selected" forValue:self.curDevice.device_id];
        //开始订阅此设备媒体状态
        mediaErrTimez = 0;
        [self subscribeMediaStatus];
    }else{
        [[ConfigDAO sharedInstance] remove:@"dev_selected"];
        NSLog(@"当前没有可选择的设备");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"devSetNotification" object:nil userInfo:nil];
}

//设置当前设备媒体状态
-(void)setMediaStatus:(StatusBean<MusicStateBean *> *)mediaStatus{
    if(_mediaStatus && mediaStatus && [_mediaStatus isNewerThan:mediaStatus])
        return;
    _mediaStatus = mediaStatus;
    NSLog(@"当前设备媒体状态:%d",mediaStatus.data.music_player.playing);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mediaSetNotification" object:nil userInfo:nil];
}

//设置用户信息
-(void)setUser:(UserBean *)user{
    _user = user;
    //订阅设备状态
    deviceErrTimez = 0;
    [self subscribeDeviceStatus];
}

-(UINavigationController*)rootNavC{
    if(self.window.rootViewController){
        return (UINavigationController*)self.window.rootViewController;
    }
    return nil;
}

#pragma mark --IFLYOSPushServiceProtocol
/**
 * socket连接成功
 */
-(void)onSockectOpenSuccess:(IFLYOSPushService *) socket{
    if(socket == mediaStatePushService){
        NSLog(@"媒体状态监听打开成功");
    }else if(socket == deviceStatePushService){
        NSLog(@"设备状态监听打开成功");
    }
}

/**
 * socket连接失败
 * error:失败原因
*/
-(void)onSockect:(IFLYOSPushService *) socket error:(NSError *) error{
    if(socket == mediaStatePushService){
        NSLog(@"媒体状态监听打开失败：%@",error);
        mediaStatePushService = nil;
        if(++mediaErrTimez > 1)
            return;
        //进行重试
        [self subscribeMediaStatus];
    }else if(socket == deviceStatePushService){
        NSLog(@"设备状态监听打开失败：%@",error);
        deviceStatePushService = nil;
        if(++deviceErrTimez > 1)
            return;
        //进行重试
        [self subscribeDeviceStatus];
    }
}
/**
 * socket 主动关闭连接回调（关闭成功后，清理socket相关东西）
 * code:关闭代码
 * reason:关闭原因
 * wasClean:是否清除
*/
-(void)onSockect:(IFLYOSPushService *) socket didCloseWithCode:(NSInteger) code reason:(NSString *) reason wasClean:(BOOL)wasClean{
    if(socket == mediaStatePushService){
        NSLog(@"媒体状态监听已关闭：%@",reason);
    }else if(socket == deviceStatePushService){
        NSLog(@"设备状态监听已关闭：%@",reason);
    }
}

/**
 * 收到的信息
 * receiveMessage : 回调信息
 */
-(void)onSockect:(IFLYOSPushService *) socket receiveMessage:(id) receiveMessage{
    NSString *json = [NSString stringWithFormat:@"%@",receiveMessage];
    if(socket == mediaStatePushService){
        StatusBean<MusicStateBean*> *statusBeanMedia = [StatusBean yy_modelWithJSON:json];
        NSLog(@"mediaStatePushService:%@",json);
        self.mediaStatus = statusBeanMedia;
    }else if(socket == deviceStatePushService){
        StatusBean<DeviceBean*> *statusBeanDevice = [StatusBean yy_modelWithJSON:json];
        //更新设备在线状态
        DeviceBean *dev = statusBeanDevice.data;
        for(DeviceBean *devBean in self.devices){
            if([devBean isEqual:dev]){
                devBean.status = dev.status;
                NSLog(@"更新了在线状态：%@",devBean.status);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onLineChangedNotification" object:nil userInfo:nil];
            }
        }
    }
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
