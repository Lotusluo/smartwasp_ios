//
//  Device.h
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import <Foundation/Foundation.h>
#import "MusicBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceBean : NSObject

//设备别名
@property(nonatomic,strong) NSString *alias;
//client_id
@property(nonatomic,strong) NSString *client_id;
//device_id
@property(nonatomic,strong) NSString *device_id;
//设备图片
@property(nonatomic,strong) NSString *image;
//设备名称
@property(nonatomic,strong) NSString *name;
//设备在线状态
@property(nonatomic,strong) NSString *status;
//设备空间
@property(nonatomic,strong) NSString *zone;
//music
@property(nonatomic,strong) MusicBean *music;
//@property(nonatomic,strong) id brand;

//设备是否在线
- (Boolean)isOnLine;

@end

NS_ASSUME_NONNULL_END
