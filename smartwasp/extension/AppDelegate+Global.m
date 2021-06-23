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

@implementation AppDelegate (Global)

//请求绑定的设备
- (void)requestBindDevices{
    if(self.user){
        [[IFLYOSSDK shareInstance] getUserDevices:^(NSInteger code) {
            if(code != 200){
                //加载错误
                NSLog(@"获取设备列表失败");
            }
        } requestSuccess:^(id _Nonnull success)  {
            //刷新绑定的设备列表
            NSArray *devices = [NSArray yy_modelArrayWithClass:DeviceBean.class json:success[@"user_devices"]];
            NSString *devValue = [[ConfigDAO sharedInstance] findByKey:@"dev"];
            for(DeviceBean *dev in devices){
                if(self.curDevice && [self.curDevice isEqual:dev]){
                    //刷新可能存在的设备信息更改
                    self.curDevice = dev;
                }else if (!self.curDevice&& [dev.device_id isEqualToString:devValue]){
                    //刷新上一次应用的设备选择记录
                    self.curDevice = dev;
                }
            }
            self.devices = [devices copy];
            if(!self.curDevice && self.devices.count > 0){
                //默认选择第一个
                self.curDevice = self.devices[0];
            }
            if(!self.curDevice){
                //设备为空
            }
        } requestFail:^(id _Nonnull error) {
            //加载错误
        }];
    }
}

//订阅求当前设备的媒体状态
-(void)subscribeMediaStatus{
    //获取当前设备媒体状态并进行订阅
    [[IFLYOSSDK shareInstance] getMusicControlState:self.curDevice.device_id statusCode:^(NSInteger code) {
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
    
    if(mediaStatePushService){
        [mediaStatePushService close];
        mediaStatePushService = nil;
    }
    //开始订阅媒体状态
    NSString *token = [IFLYOSSDK shareInstance].getToken;
    if (token){
        mediaStatePushService = [IFLYOSPushService createSocket:token command:@"connect" fromType:@"ALIAS" deviceId:self.curDevice.device_id];
        mediaStatePushService.delegate = (id)self;
        [mediaStatePushService open];
    }
}

//订阅当前用户的设备状态
-(void)subscribeDeviceStatus{
    if(deviceStatePushService){
        [deviceStatePushService close];
        deviceStatePushService = nil;
    }
    //开始订阅媒体状态
    NSString *token = [IFLYOSSDK shareInstance].getToken;
    if (token){
        deviceStatePushService = [IFLYOSPushService createSocket:token command:@"connect" fromType:@"ACCOUNT" deviceId:self.user.user_id];
        deviceStatePushService.delegate = (id)self;
        [deviceStatePushService open];
    }
}

//跳转登陆页面
-(void)toLogin{
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
