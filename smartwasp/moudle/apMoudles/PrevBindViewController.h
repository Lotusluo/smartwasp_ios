//
//  PrevBindViewController.h
//  smartwasp
//
//  Created by luotao on 2021/6/24.
//

#import <UIKit/UIKit.h>
#import "ApAuthCode.h"


extern NSString * _Nullable SSID;
extern NSString * _Nullable PWD;
extern ApAuthCode * _Nullable AUTHCODE;

typedef NS_ENUM(NSUInteger,BindType){
    SCREEN_TYPE = 1,
    NO_SCREEN_TYPE = 1 << 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface PrevBindViewController : UIViewController

//绑定的类型
@property(nonatomic,assign)BindType mBindType;
@property(nonatomic,copy)NSString *clientID;

@end

NS_ASSUME_NONNULL_END
