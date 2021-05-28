//
//  IFLYOSBLEManager.h
//  iflyosSDKForiOS
//
//  Created by admin on 2018/11/8.
//  Copyright © 2018年 iflyosSDKForiOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN
@class IFLYOSBLEManager;
@protocol IFLYOSBLEManagerDelegate<NSObject>

/**
 *  蓝牙状态
 */
-(void) callBack:(IFLYOSBLEManager *) manager state:(CBManagerState) state;

/**
 *  获取搜索到的蓝牙信息
 */
-(void) callBack:(IFLYOSBLEManager *) manager peripheral:(CBPeripheral *) peripheral;

/**
 *  正在连接的蓝牙设备
 */
-(void) callBack:(IFLYOSBLEManager *) manager connecting:(CBPeripheral *) peripheral;

/**
 *  连接蓝牙是否成功
 */
-(void) callBack:(IFLYOSBLEManager *) manager peripheral:(CBPeripheral *) peripheral connect:(BOOL) isSccuess;

/**
 *  蓝牙断开连接
 */
-(void) callBack:(IFLYOSBLEManager *) manager central:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *) error;

/**
 *  蓝牙已准备可发送消息
 */
-(void) callBack:(IFLYOSBLEManager *) manager peripheral:(CBPeripheral *) peripheral isReady:(BOOL) isReady;

/**
 *  发送蓝牙后回调的信息
 */
-(void) callBack:(IFLYOSBLEManager *) manager peripheral:(CBPeripheral *) peripheral message:(NSString *) message;

@end

@interface IFLYOSBLEManager : NSObject
/**
 *  单例
 */
+(IFLYOSBLEManager *) shareInstance;

//描述
@property (nonatomic) id<IFLYOSBLEManagerDelegate> delegate;

/**
 *  添加代理
 */
-(void) addBLEDelegate:(id<IFLYOSBLEManagerDelegate>) delegate;

/**
 *  移除代理
 */
-(void) removeBLEDelegate;

/**
 *  开始搜索蓝牙
 */
-(void) startScanBluetooth;

/**
 *  停止搜索蓝牙
 */
-(void) stopScanBluetooth;

/**
 *  连接蓝牙
 */
-(void) connectBluetooth:(CBPeripheral *) peripheral;

/**
 *  断开蓝牙
 */
-(void) disconnectBluetooth:(CBPeripheral *) peripheral;

/**
 *  关闭当前蓝牙通道
 */
-(void) closePeripheralChannel;
/**
 *  发送蓝牙数据
 *  ssid : ssid
 *  password : 密码
 *  reauth : 是否重新授权，默认为YES
 */
-(void) sendBluetooth:(NSString *) ssid password:(NSString *)password reauth:(BOOL)reauth;

@end

NS_ASSUME_NONNULL_END
