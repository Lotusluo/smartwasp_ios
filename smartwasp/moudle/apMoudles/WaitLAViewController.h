//
//  WaitLAViewController.h
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaitLAViewController : UIViewController

//ssid
@property(nonatomic,copy)NSString *ssid;
//密码
@property(nonatomic,copy)NSString *pwd;
//授权码
@property(nonatomic,copy)NSString *authCode;
//图片资料
@property(nonatomic,copy)NSString *iconPath;

@end

NS_ASSUME_NONNULL_END
