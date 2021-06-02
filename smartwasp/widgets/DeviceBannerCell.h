//
//  DeviceBannerCell.h
//  smartwasp
//
//  Created by luotao on 2021/5/18.
//

#import <UIKit/UIKit.h>
#import "DeviceBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceBannerCell : UICollectionViewCell

//设备信息
@property(nonatomic,strong) DeviceBean* device;

//渲染控件
-(void) render:(DeviceBean*) device;

@end

NS_ASSUME_NONNULL_END
