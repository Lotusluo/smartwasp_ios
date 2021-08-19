//
//  Toolbar.h
//  smartwasp
//
//  Created by luotao on 2021/4/19.
//

#import <UIKit/UIKit.h>
#import "DeviceBean.h"


NS_ASSUME_NONNULL_BEGIN

@interface Toolbar : UIView

+(Toolbar*)newView;
//当前显示的设备信息
@property(nonatomic,strong) DeviceBean *device;
@property(nonatomic) IBInspectable BOOL canSearch;
//更新信息
-(void)update;
//暂无设备
- (void)setEmpty;
//音乐开始跳动
- (void)startJump;
//音乐停止跳动
- (void)stopJump;
-(void)tempDo;

@end

NS_ASSUME_NONNULL_END
