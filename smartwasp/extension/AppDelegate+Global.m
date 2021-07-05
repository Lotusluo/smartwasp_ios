//
//  AppDelegate+Global.h
//  smartwasp
//
//  Created by luotao on 2021/4/21.
//
#import "AppDelegate.h"
#import "AppDelegate+Global.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "IFlyOSBean.h"
#import "UIViewHelper.h"

@implementation AppDelegate (Global)

//请求绑定的设备
- (void)requestBindDevices{
    __weak typeof(self) SELF = self;
    if(self.user && NEED_MAIN_REFRESH_DEVICES){
        [[IFLYOSSDK shareInstance] getUserDevices:^(NSInteger code) {
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
    [[IFLYOSSDK shareInstance] getDeviceInfo:self.curDevice.device_id
                                  statusCode:^(NSInteger statusCode) {
    } requestSuccess:^(id _Nonnull data) {
        DeviceBean *dev = [DeviceBean yy_modelWithDictionary:data];
        dev.device_id = self.curDevice.device_id;
        for(DeviceBean *devBean in self.devices){
            if([devBean isEqual:dev]){
                devBean.status = dev.status;
                NSLog(@"更新了在线状态：%@",devBean.status);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onLineChangedNotification" object:nil userInfo:nil];
            }
        }
    } requestFail:^(id _Nonnull data) {
    }];
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
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:loginVc];
    [navVc setNavigationBarHidden:YES animated:YES];
    navVc.navigationBar.topItem.title = @"";
    self.window.rootViewController = navVc;
}

//设置主界面
-(void)toMain{
    MainViewController *tabVc =[[MainViewController alloc] init];
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:tabVc];
    //默认隐藏导航条
    [navVc setNavigationBarHidden:YES animated:YES];
    navVc.navigationBar.topItem.title = @"";
    self.window.rootViewController = navVc;
}

@end
