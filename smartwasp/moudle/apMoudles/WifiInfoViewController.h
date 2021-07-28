//
//  WifiInfoViewController.h
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import <UIKit/UIKit.h>
#import "ApClientBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface WifiInfoViewController : UIViewController

@property(nonatomic,copy)NSString *ssid;
@property(nonatomic,strong)ApClientBean *client;
@end

NS_ASSUME_NONNULL_END
