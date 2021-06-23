//
//  StatusBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatusBean<T> : NSObject

//数据
@property(nonatomic,strong) T data;

//订阅信息类型
@property(nonatomic,strong) NSString* type;

//订阅信息时间戳
@property(nonatomic,strong) NSString* timestamp;

-(BOOL) isNewerThan:(StatusBean *) other;

@end

NS_ASSUME_NONNULL_END
