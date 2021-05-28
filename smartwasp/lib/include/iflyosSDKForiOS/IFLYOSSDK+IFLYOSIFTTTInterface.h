//
//  IFLYOSSDK+IFLYOSIFTTTInterface.h
//  iflyosSDKForiOS
//
//  Created by 周经伟 on 2020/11/10.
//  Copyright © 2020 iflyosSDKForiOS. All rights reserved.
//

#import "IFLYOSSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface IFLYOSSDK (IFLYOSIFTTTInterface)

/**
 *  获取操作类型列表
 *  execType : voice 或 time
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getIFTTTExecType:(NSString *) execType
                 statusCode:(void (^)(NSInteger)) statusCode
             requestSuccess:(void (^)(id _Nonnull)) successData
             requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  获取操作类型列表
 *  execType : voice 或 time
 *  actionType :  操作类型
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getIFTTTExecTypeActionTypes:(NSString *) execType
                         actionType:(NSString *) actionType
                         statusCode:(void (^)(NSInteger)) statusCode
                     requestSuccess:(void (^)(id _Nonnull)) successData
                        requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  添加训练计划
 *  execType : voice 或 time
 *  execData : 数据
 *  token : 训练计划唯一token，token不为空时更新数据，token为空时添加数据
 *  operations : 操作步骤数组
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) addIFTTT:(NSString *) execType
        execData:(NSDictionary *) execData
      operations:(NSArray *) operations
           token:(NSString *) token
      statusCode:(void (^)(NSInteger)) statusCode
  requestSuccess:(void (^)(id _Nonnull)) successData
     requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  查询moreItem数据
 *  execType:操作类型
 *  deviceId: 设备ID
 *  actionType:操作类型
 *  body:请求参数
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getIFTTTExecTypeMoreItem:(NSString *) execType
                      actionType:(NSString *) actionType
                        deviceId:(NSString *) deviceId
                            body:(NSDictionary *) body
                      statusCode:(void (^)(NSInteger)) statusCode
                  requestSuccess:(void (^)(id _Nonnull)) successData
                     requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  查询训练计划
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getIFTTTs:(void (^)(NSInteger)) statusCode
  requestSuccess:(void (^)(id _Nonnull)) successData
     requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  查询训练计划详情
 *  planToken:训练计划token
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getIFTTTWithPlanToken:(NSString *) planToken
                   statusCode:(void (^)(NSInteger)) statusCode
               requestSuccess:(void (^)(id _Nonnull)) successData
                  requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  删除训练计划
 *  planTokens:训练计划token（数组）
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) deleteIFTTTWithPlanTokens:(NSArray *) planTokens
                   statusCode:(void (^)(NSInteger)) statusCode
               requestSuccess:(void (^)(id _Nonnull)) successData
                   requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  检查唤醒语料是否合法
 *  text:唤醒语料
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getIFTTTCheck:(NSString *) text
           statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

@end

NS_ASSUME_NONNULL_END
