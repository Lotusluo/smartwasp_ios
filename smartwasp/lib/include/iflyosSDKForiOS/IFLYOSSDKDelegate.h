//
//  IFLYOSSDKDelegate.h
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#ifndef IFLYOSSDKDelegate_h
#define IFLYOSSDKDelegate_h

#import <Foundation/Foundation.h>
@protocol IFLYOSsdkDelegate
/**
 *  新页面打开
 *  tag : 标识符
 *  noBack : 禁止手势返回（1:禁止 ， 0:不禁止）
 */
-(void) openNewPage:(NSString *) tag noBack:(NSNumber *) noBack;
/**
 *  关闭页面打开
 */
-(void) closePage;

/**
 * 网页加载完成时，如果读取到页面内带有形如
 * <meta name="head-color">#FFFFFF</meta>
 * 的标签时，将回调颜色
 */
-(void) updateHeaderColor:(NSString *) color;

/**
 * 网页加载完成时，将回调标题
 */
-(void) updateTitle:(NSString *) title;

/**
 * 打开外部浏览器
 * url : 地址
 */
-(void) openNewBrower:(NSString *) url;
@end

@protocol IFLYOSsdkLoginDelegate
/**
 *  新页面打开
 *  tag : 标识符
 *  noBack : 禁止手势返回（1:禁止 ， 0:不禁止）
 */
-(void) openNewPage:(NSString *) tag noBack:(NSNumber *) noBack;

/**
 *  登录成功
 */
-(void) onLoginSuccess;

/**
 *  登录失败
 */
-(void) onLoginFailed:(NSInteger) type error:(NSError *) error;

/**
 *  注销成功
 */
-(void) onLogoutSuccess;

/**
 *  注销失败
 */
-(void) onLogoutFailed:(NSInteger) type error:(NSError *) error;

/**
 *  注销账号成功
 */
-(void) onUserRevokeSuccess;

/**
 *  注销账号失败
 */
-(void) onUserRevokeFail:(NSInteger) type error:(NSError *) error;

@end

@protocol IFLYOSsdkAuthDelegate
/**
 *  授权成功
 */
-(void) onAuthSuccess;

/**
 *  授权失败
 */
-(void) onAuthFailed;

/**
 *  拒绝授权
 */
-(void) onAuthReject;
@end

@protocol IFLYOSsdkBindDelegate
/**
 *  绑定成功
 */
-(void) onBindSuccess;

/**
 *  绑定失败
 */
-(void) onBindFailed:(id) error;
@end

@protocol IFLYOSsdkIAPDelegate
/**
 *  订单
 *  productId : 商品id
 *  tradeNo : 订单号
 */
-(void) onApplePay:(NSString *) productId tradeNo:(NSString *) tradeNo;

/**
 *  是否可支付
 *  canPay : 是否可以支付
 *  error : 错误原因
 */
-(void) canPay:(BOOL) canPay error:(NSString *) error;

/**
 *  再次校验一次
 *  tradeNo : 订单号
 */
-(void) onVeriflyAgain:(NSString *) tradeNo;
@end
#endif /* IFLYOSSDKDelegate_h */
