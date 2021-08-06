//
//  AppDelegate.m
//  smartwasp
//
//  Created by luotao on 2021/4/8.
//

#import "AppDelegate.h"
#import "CodingUtil.h"
#import "GSMonitorKeyboard.h"
#import "JCGCDTimer.h"
#import <Bugly/Bugly.h>
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "Loading.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "IFlyOSBean.h"
#import "UIViewHelper.h"
#import "Reachability.h"


//定义小黄蜂appid
#define APPID @"28e49106-5d37-45fd-8ac8-c8d1f21356f5"
//bugly appid
#define BUGDLY_APPID @"ebfbb9b728"


BOOL NEED_MAIN_REFRESH_DEVICES = YES;
BOOL NEED_TIP = YES;

@interface AppDelegate ()<IFLYOSPushServiceProtocol,UIGestureRecognizerDelegate>{
    NSInteger mediaErrTimez;
    NSInteger deviceErrTimez;
    NSString *mediaErrNamez;
    NSString *deviceErrNamez;
}

@property (nonatomic) Reachability *hostReachability;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"屏幕大小:%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    [self doWords];
    [self toApp];
    return YES;
}

//在子线程处理耗时动作
-(void)doWords{
    [Bugly startWithAppId:BUGDLY_APPID];
    [[IFLYOSSDK shareInstance] initAppId:APPID schema:@"smartwasp" loginType:DEFAULT];
//    [[IFLYOSSDK shareInstance] setDebugModel:NO];
    [[GSMonitorKeyboard sharedMonitorMethod] run];
    //恢复用户数据
    NSString *usrValue = [[ConfigDAO sharedInstance] findByKey:@"usr"];
    if(usrValue){
        NSData *usrData = [CodingUtil dataFromHexString:usrValue];
        self.user = [NSKeyedUnarchiver unarchiveObjectWithData:usrData];
    }
    [self setUpSdImage];
}

//进入APP界面
-(void)toApp{
    self.window =[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *navigator = [[UINavigationController alloc] init];
    self.window.rootViewController = navigator;
    [self.window makeKeyAndVisible];
    if(self.user){
        [self toMain];
    }else{
        [self toLogin];
    }
    [self netObserver];
}

//网络观察器
-(void)netObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    UIViewController *firstVv = self.rootNavC.viewControllers[0];
    switch (netStatus){
        case NotReachable:{
            if(firstVv && [firstVv respondsToSelector:@selector(netNotReachable)]){
                [firstVv performSelector:@selector(netNotReachable)];
            }
            break;
        }
        case ReachableViaWiFi:
        case ReachableViaWWAN:{
            if(firstVv && [firstVv respondsToSelector:@selector(netReachable)]){
                [firstVv performSelector:@selector(netReachable)];
            }
            break;
        }
    }
}

//初始化SDImage
-(void)setUpSdImage{
    //Add a custom read-only cache path
    NSString *bundledPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CustomPathImages"];
    [SDImageCache sharedImageCache].additionalCachePathBlock = ^NSString * _Nullable(NSString * _Nonnull key) {
        NSString *fileName = [[SDImageCache sharedImageCache] cachePathForKey:key].lastPathComponent;
        return [bundledPath stringByAppendingPathComponent:fileName.stringByDeletingPathExtension];
    };
    
    if (@available(iOS 14, tvOS 14, macOS 11, watchOS 7, *)) {
        // iOS 14 supports WebP built-in
        [[SDImageCodersManager sharedManager] addCoder:[SDImageAWebPCoder sharedCoder]];
    } else {
        // iOS 13 does not supports WebP, use third-party codec
        [[SDImageCodersManager sharedManager] addCoder:[SDImageWebPCoder sharedCoder]];
    }
    if (@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)) {
        // For HEIC animated image. Animated image is new introduced in iOS 13, but it contains performance issue for now.
        [[SDImageCodersManager sharedManager] addCoder:[SDImageHEICCoder sharedCoder]];
    }
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
        mediaErrTimez = 0;
        [self subscribeMediaStatusOnce];
        NSLog(@"媒体状态监听打开成功");
    }else if(socket == deviceStatePushService){
        deviceErrTimez = 0;
        [self subscribeDeviceStatusOnce];
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
        [JCGCDTimer canelTimer:mediaErrNamez];
        mediaErrNamez = [JCGCDTimer timerTask:^{
            [self subscribeMediaStatus];
        } start:2 interval:0 repeats:NO async:NO];
    }else if(socket == deviceStatePushService){
        NSLog(@"设备状态监听打开失败：%@",error);
        deviceStatePushService = nil;
        if(++deviceErrTimez > 1)
            return;
        //进行重试
        [JCGCDTimer canelTimer:deviceErrNamez];
        deviceErrNamez = [JCGCDTimer timerTask:^{
            [self subscribeDeviceStatus];
        } start:2 interval:0 repeats:NO async:NO];
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
        mediaStatePushService = nil;
        if(++mediaErrTimez > 1)
            return;
        //进行重试
        [JCGCDTimer canelTimer:mediaErrNamez];
        mediaErrNamez = [JCGCDTimer timerTask:^{
            [self subscribeMediaStatus];
        } start:2 interval:0 repeats:NO async:NO];
    }else if(socket == deviceStatePushService){
        NSLog(@"设备状态监听已关闭：%@",reason);
        deviceStatePushService = nil;
        if(++deviceErrTimez > 1)
            return;
        //进行重试
        [JCGCDTimer canelTimer:deviceErrNamez];
        deviceErrNamez = [JCGCDTimer timerTask:^{
            [self subscribeDeviceStatus];
        } start:2 interval:0 repeats:NO async:NO];
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
        self.mediaStatus = statusBeanMedia;
    }else if(socket == deviceStatePushService){
        StatusBean<DeviceBean*> *statusBeanDevice = [StatusBean yy_modelWithJSON:json];
        //更新设备在线状态
        DeviceBean *dev = statusBeanDevice.data;
        for(DeviceBean *devBean in self.devices){
            if([devBean isEqual:dev]){
                devBean.status = dev.status;
                NSLog(@"更新设备在线状态：%@,%@",devBean.name,devBean.status);
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onLineChangedNotification" object:nil userInfo:nil];
    }
}

//请求绑定的设备
- (void)requestBindDevices{
    __weak typeof(self) SELF = self;
    if(self.user && NEED_MAIN_REFRESH_DEVICES){
        [[IFLYOSSDK shareInstance] getUserDevices:^(NSInteger code) {
            [Loading dismiss];
            NEED_MAIN_REFRESH_DEVICES = NO;
        } requestSuccess:^(id _Nonnull success)  {
            //刷新绑定的设备列表
            NSArray *devices = [NSArray yy_modelArrayWithClass:DeviceBean.class json:success[@"user_devices"]];
            if(devices && devices.count > 0){
                SELF.devices = devices;
            }else{
                SELF.devices = nil;
            }
            
        } requestFail:^(id _Nonnull error) {
            NSLog(@"devices error:%@",error);
            //加载错误
            if([NSStringFromClass([error class]) containsString:@"_NSInlineData"]){
                NSString * errMsg = [[NSString alloc] initWithData:error encoding:NSUTF8StringEncoding];
                IFlyOSBean *osBean = [IFlyOSBean yy_modelWithJSON:errMsg];
                if(osBean.code == 401){
                    //401错误为token失效，需要重新登陆
                    [UIViewHelper showAlert:@"登陆状态失效，是否重新登陆？" target:self.rootNavC callBack:^{
                        [[ConfigDAO sharedInstance] remove:@"usr"];
                        [SELF toLogin];
                    } negative:YES];
                }
            }
            SELF.devices = nil;
        }];
    }
}

//订阅求当前设备的媒体状态
-(void)subscribeMediaStatus{
    [self disSubscribeMediaStatus];
    //开始订阅媒体状态
    NSString *token = [IFLYOSSDK shareInstance].getToken;
    if (token){
        mediaStatePushService = [IFLYOSPushService createSocket:token command:@"connect" fromType:@"ALIAS" deviceId:self.curDevice.device_id];
        mediaStatePushService.delegate = (id)self;
        [mediaStatePushService open];
    }
}

-(void)subscribeMediaStatusOnce{
    //获取当前设备媒体状态并进行订阅
    [[IFLYOSSDK shareInstance] getMusicControlState:self.curDevice.device_id statusCode:^(NSInteger code) {
    } requestSuccess:^(id _Nonnull data) {
        MusicStateBean *musicStateBean = [MusicStateBean yy_modelWithJSON:data];
        StatusBean<MusicStateBean*> *statusBean = StatusBean.new;
        statusBean.data = musicStateBean;
        self.mediaStatus = statusBean;
    } requestFail:^(id _Nonnull data) {
    }];
}

//取消订阅媒体状态
-(void)disSubscribeMediaStatus{
    if(mediaStatePushService){
        [mediaStatePushService close];
        mediaStatePushService = nil;
    }
}

//订阅当前用户的设备状态
-(void)subscribeDeviceStatus{
    [self disSubscribeDeviceStatus];
    //开始订阅媒体状态
    NSString *token = [IFLYOSSDK shareInstance].getToken;
    if (token){
        deviceStatePushService = [IFLYOSPushService createSocket:token command:@"connect" fromType:@"ACCOUNT" deviceId:self.user.user_id];
        deviceStatePushService.delegate = (id)self;
        [deviceStatePushService open];
    }
}

-(void)subscribeDeviceStatusOnce{
    for(DeviceBean *devBean in self.devices){
        [[IFLYOSSDK shareInstance] getDeviceInfo:devBean.device_id
                                      statusCode:^(NSInteger statusCode) {
        } requestSuccess:^(id _Nonnull data) {
            DeviceBean *dev = [DeviceBean yy_modelWithDictionary:data];
            devBean.status = dev.status;
            NSLog(@"更新设备在线状态1：%@,%@",devBean.name,devBean.status);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onLineChangedNotification" object:nil userInfo:nil];
        } requestFail:^(id _Nonnull data) {
        }];
    }
   
}

//取消当前用户的设备状态
-(void)disSubscribeDeviceStatus{
    if(deviceStatePushService){
        [deviceStatePushService close];
        deviceStatePushService = nil;
    }
}

//跳转登陆页面
-(void)toLogin{
    [self disSubscribeMediaStatus];
    [self disSubscribeDeviceStatus];
    self.mediaStatus = nil;
    self.devices = nil;
    self.user = nil;
    NEED_MAIN_REFRESH_DEVICES = YES;
    LoginViewController *loginVc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navigator = self.rootNavC;
    [navigator setViewControllers:@[loginVc] animated:NO];
    navigator.navigationBar.topItem.title = @"";
}

//设置主界面
-(void)toMain{
    MainViewController *tabVc =[[MainViewController alloc] init];
    UINavigationController *navigator = self.rootNavC;
    [navigator setViewControllers:@[tabVc] animated:NO];
    navigator.interactivePopGestureRecognizer.delegate = self;
    [navigator.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    //去除横线
    [navigator.navigationBar setShadowImage:[[UIImage alloc]init]];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return self.rootNavC.viewControllers.count > 1;
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
