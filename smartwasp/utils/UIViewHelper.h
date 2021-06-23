//
//  UIViewHelper.h
//  smartwasp
//
//  Created by luotao on 2021/6/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ISWDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewHelper : NSObject

//通过名称加载控件
+(UIView*)loadNibByName:(NSString*)name;
//添加文本
+(BOOL)attachText:(NSString*)text widget:(UIView*)widget;
//添加点击事件
+(void)attachClick:(UIView*)view target:(nullable id)target action:(nullable SEL)action;
//获取当前附着的VC
+(UIViewController*)getAttachController:(UIView*)view;

@end

NS_ASSUME_NONNULL_END
