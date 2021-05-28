//
//  IFLYOSPushServiceProtocol.h
//  iflyosPushService
//
//  Created by 周经伟 on 2020/8/20.
//  Copyright © 2020 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class IFLYOSPushService;
@protocol IFLYOSPushServiceProtocol <NSObject>

/**
 * socket连接成功
 */
-(void) onSockectOpenSuccess:(IFLYOSPushService *) socket;
/**
 * socket连接失败
 * error:失败原因
*/
-(void) onSockect:(IFLYOSPushService *) socket error:(NSError *) error;
/**
 * socket 主动关闭连接回调（关闭成功后，清理socket相关东西）
 * code:关闭代码
 * reason:关闭原因
 * wasClean:是否清除
*/
-(void) onSockect:(IFLYOSPushService *) socket didCloseWithCode:(NSInteger) code reason:(NSString *) reason wasClean:(BOOL)wasClean;

/**
 * 收到的信息
 * receiveMessage : 回调信息
 */
-(void) onSockect:(IFLYOSPushService *) socket receiveMessage:(id) receiveMessage;
@end

NS_ASSUME_NONNULL_END
