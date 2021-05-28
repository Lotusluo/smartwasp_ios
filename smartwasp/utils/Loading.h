//
//  LoadingUtil.h
//  smartwasp
//
//  Created by luotao on 2021/4/10.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

//加载框取消
typedef void(^OnDismiss)(void);

NS_ASSUME_NONNULL_BEGIN

@interface Loading : UIView

//生成一个加载控件
+(void) show:(OnDismiss)onDismiss;

//取消弹出框
+(void) dismiss;

@end

NS_ASSUME_NONNULL_END

