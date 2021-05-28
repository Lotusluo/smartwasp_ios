//
//  IFLYOSUIColor+IFLYOSColorUtil.h
//  iflyosSDK
//
//  Created by admin on 2018/8/27.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFLYOSUIColor+IFLYOSColorUtil.h"

@interface UIColor(IFLYOSUIColor_IFLYOSColorUtil)
/**
 * 根据#FFFFFF获取颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

/**
 * 根据#FFFFFF获取颜色
 * alpha 通道
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat) alpha;

/**
 *  随机颜色
 */
+ (UIColor *)randomColor ;

/**
 * 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 * 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color CGRect:(CGRect) rect;

//设置状态栏颜色
+ (void)setStatusBarBackgroundColor:(UIColor *)color ;
@end
