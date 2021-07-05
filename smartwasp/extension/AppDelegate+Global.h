//
//  AppDelegate+Global.h
//  smartwasp
//
//  Created by luotao on 2021/4/21.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Global)

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

NS_ASSUME_NONNULL_END
