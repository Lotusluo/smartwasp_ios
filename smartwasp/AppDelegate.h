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

//已经绑定的设备列表
@property(nonatomic,strong)NSArray<DeviceBean*> *devices;

//当前选择的设备
@property(nonatomic,strong)DeviceBean *curDevice;

//当前设备的媒体状态
@property(nonatomic,strong)StatusBean<MusicStateBean*> *mediaStatus;

@property(nonatomic,strong)UINavigationController *rootNavC;

@end

