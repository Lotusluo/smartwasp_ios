//
//  AppDelegate+Global.h
//  smartwasp
//
//  Created by luotao on 2021/4/21.
//
#import "AppDelegate.h"
#import "AppDelegate+Global.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import "ConfigDAO.h"
#import "NSObject+YYModel.h"
#import "LoginViewController.h"
#import "MainViewController.h"

@implementation AppDelegate (Global)

//请求绑定的设备
- (void) requestBindDevices{
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
