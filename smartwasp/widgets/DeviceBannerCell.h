//
//  DeviceBannerCell.h
//  smartwasp
//
//  Created by luotao on 2021/5/18.
//

#import <UIKit/UIKit.h>
#import "Device.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceBannerCell : UICollectionViewCell

//设备信息
@property(nonatomic,strong) Device* device;

//渲染控件
-(void) render:(Device*) device;

@end

NS_ASSUME_NONNULL_END
