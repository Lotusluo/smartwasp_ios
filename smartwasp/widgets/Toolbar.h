//
//  Toolbar.h
//  smartwasp
//
//  Created by luotao on 2021/4/19.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface Toolbar : UIView

+(Toolbar*)newView;
//设置设备是否在线
- (void)setDevStatus:(Boolean) isOnline;
//设置设备名称
- (void)setDevName:(NSString*)devName;
//暂无设备
- (void)setEmpty;
//音乐开始跳动
- (void)startJump;
//音乐停止跳动
- (void)stopJump;

@end

NS_ASSUME_NONNULL_END
