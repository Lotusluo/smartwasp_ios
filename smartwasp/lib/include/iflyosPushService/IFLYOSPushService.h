//
//  IFLYOSPushService.h
//  iflyosPushService
//
//  Created by 周经伟 on 2020/8/20.
//  Copyright © 2020 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFLYOSPushServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface IFLYOSPushService : NSObject
@property(copy,nonatomic) NSString* fromType;//订阅类型
@property(copy,nonatomic) NSString* deviceId;//订阅推送的唯一标识
@property(copy,nonatomic) NSString* command;//推送ID
@property(copy,nonatomic) NSString* token;

//代理
@property(weak,nonatomic) id<IFLYOSPushServiceProtocol> delegate;

/**
 * 创建wss
*/
+(IFLYOSPushService *) createSocket:(NSString * _Nonnull) token
                            command:(NSString * _Nonnull) command
                           fromType:(NSString * _Nonnull) fromType
                           deviceId:(NSString * _Nonnull) deviceId;


/**
 *  wss连接打开
 */
-(void) open;

/**
 *  wss关闭
 */
-(void) close;
@end

NS_ASSUME_NONNULL_END
