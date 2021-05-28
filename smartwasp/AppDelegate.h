//
//  AppDelegate.h
//  smartwasp
//
//  Created by luotao on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Device.h"

static inline UIEdgeInsets sgm_safeAreaInset(UIView *view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//用户登陆的数据
@property (nonatomic,strong) User *user;

//已经绑定的设备列表
@property (nonatomic,strong) NSArray<Device*> *devices;

//当前选择的设备
@property (nonatomic,strong) Device *curDevice;

//进入主界面
- (void) toMain;

@end

