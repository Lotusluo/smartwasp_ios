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
- (void) requestBindDevices;


//进入主界面
-(void)toMain;


//进入登陆界面
-(void)toLogin;

@end

NS_ASSUME_NONNULL_END
