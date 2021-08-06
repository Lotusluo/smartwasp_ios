//
//  AppDelegate.h
//  smartwasp
//
//  Created by luotao on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "UserBean.h"
#import "DeviceBean.h"
#import "StatusBean.h"
#import "MusicStateBean.h"
#import "ConfigDAO.h"
#import "ConfigBean.h"
#import "NSObject+YYModel.h"
#import "ApAuthCode.h"
#import <iflyosPushService/IFLYOSPushService.h>
#import <iflyosPushService/IFLYOSPushServiceProtocol.h>
#import <iflyosSDKForiOS/iflyosCommonSDK.h>

extern BOOL NEED_MAIN_REFRESH_DEVICES;
extern BOOL NEED_TIP;

static inline UIEdgeInsets sgm_safeAreaInset(UIView *view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    @private
    IFLYOSPushService *mediaStatePushService;
    @private
    IFLYOSPushService *deviceStatePushService;
}

@property(strong, nonatomic)UIWindow *window;

//用户登陆的数据
@property(nonatomic,strong)UserBean *user;

//配置文件
@property(nonatomic,strong)ConfigBean *configBean;

//已经绑定的设备列表
@property(nonatomic,strong)NSArray<DeviceBean*> *devices;

//当前选择的设备
@property(nonatomic,strong)DeviceBean *curDevice;

//当前设备的媒体状态
@property(nonatomic,strong)StatusBean<MusicStateBean*> *mediaStatus;

@property(nonatomic,strong)UINavigationController *rootNavC;


//请求绑定的数据
-(void)requestBindDevices;

//订阅当前设备的媒体状态
-(void)subscribeMediaStatus;
-(void)subscribeMediaStatusOnce;

//取消订阅媒体状态
-(void)disSubscribeMediaStatus;

//订阅当前用户的设备状态
-(void)subscribeDeviceStatus;
-(void)subscribeDeviceStatusOnce;

//取消当前用户的设备状态
-(void)disSubscribeDeviceStatus;

//进入主界面
-(void)toMain;

//进入登陆界面
-(void)toLogin;

@end

