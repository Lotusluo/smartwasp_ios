//
//  AppDelegate.h
//  smartwasp
//
//  Created by luotao on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "UserBean.h"
#import "DeviceBean.h"

extern BOOL NEED_REFRESH_DEVICES_DETAIL;

static inline UIEdgeInsets sgm_safeAreaInset(UIView *view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//用户登陆的数据
@property (nonatomic,strong) UserBean *user;

//已经绑定的设备列表
@property (nonatomic,strong) NSArray<DeviceBean*> *devices;

//当前选择的设备
@property (nonatomic,strong) DeviceBean *curDevice;


//进入主界面
- (void) toMain;

@end

