//
//  DcCDialog.h
//  smartwasp
//
//  Created by luotao on 2021/4/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//设备被选择后回调接口
typedef void (^didSelectIndex)(NSInteger);

@interface DeviceDialog : UIView

//构建设备选择弹出框
+(DeviceDialog*)create;

@end

NS_ASSUME_NONNULL_END
