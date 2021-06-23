//
//  BaseTabViewController.h
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import <UIKit/UIKit.h>
#import "DeviceBean.h"
#import "MusicStateBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotifyViewController : UIViewController

-(void)devSetObserver:(NSNotification* __nullable)notification;

@end

NS_ASSUME_NONNULL_END
