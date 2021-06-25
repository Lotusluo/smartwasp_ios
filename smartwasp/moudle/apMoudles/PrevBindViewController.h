//
//  PrevBindViewController.h
//  smartwasp
//
//  Created by luotao on 2021/6/24.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,BindType){
    SCREEN_TYPE = 1,
    NO_SCREEN_TYPE = 1 << 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface PrevBindViewController : UIViewController

//绑定的类型
@property(nonatomic,assign)BindType mBindType;
//ssid
@property(nonatomic,copy)NSString *ssid;
//密码
@property(nonatomic,copy)NSString *pwd;
//授权码
@property(nonatomic,copy)NSString *authCode;

@end

NS_ASSUME_NONNULL_END
