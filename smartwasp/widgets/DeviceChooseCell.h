//
//  DeviceChooseCell.h
//  smartwasp
//
//  Created by luotao on 2021/4/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceChooseCell : UITableViewCell

//设置设备是否在线
- (void) setDevStatus:(Boolean) isOnline;
//设置设备名称
- (void) setDevName:(NSString*)devName;

@end

NS_ASSUME_NONNULL_END
