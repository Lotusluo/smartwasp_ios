//
//  IFLYOSConfig.h
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFLYOSConfig : NSObject
//数据字典
@property(nonatomic,strong) NSMutableDictionary *rootDict;
//数据字典
@property(nonatomic,strong) NSMutableDictionary *iOSConfigDict;
//服务器地址
@property(nonatomic,copy) NSString *serverAddress;
//web服务器地址
@property(nonatomic,copy) NSString *webServerAddress;
//登陆授权地址
@property(nonatomic,copy) NSString *authAddress;
//SDK 服务器地址
@property(nonatomic,copy) NSString *sdkServerAddress;
//小沃 地址
@property(nonatomic,copy) NSString *xiaowoServerAddress;
//网络超时
@property(nonatomic,assign) float requestTimeout;
//版本
@property(nonatomic,copy) NSString *sdkVersion;
//主题色
@property(nonatomic,copy) NSString *themeColor;

/**
 *  单例
 */
+(IFLYOSConfig *) shareInstance;
//xmlReader解析XML
-(void) initXMLReader;
@end
