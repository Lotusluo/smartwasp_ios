//
//  DeviceSetViewController.h
//  smartwasp
//
//  Created by luotao on 2021/6/17.
//

#import <UIKit/UIKit.h>
#import "DeviceBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceSetViewController : UIViewController

//设备ID
@property(nonatomic,strong)DeviceBean *deviceBean;

//静态生成
+(DeviceSetViewController *) createNewPage:(DeviceBean *) deviceBean;

//技能数组
@property(nonatomic,strong)NSArray *skillArray;

@end


@interface BottomLineView : UIView

@end

@interface NSScrollView : UIScrollView

@end

NS_ASSUME_NONNULL_END
