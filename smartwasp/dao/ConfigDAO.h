//
//  AppDelegate.h
//  smartwasp
//
//  Created by luotao on 2021/4/16.
//

#import <Foundation/Foundation.h>
#import "ConfigDAO.h"

@interface ConfigDAO : NSObject

+ (ConfigDAO*)sharedInstance;

//插入kv方法
-(BOOL) setKey:(NSString*)key forValue:(NSString*) value;

//删除kv方法
-(int) remove:(NSString*)key;

//按照k查询数据方法
-(NSString*) findByKey:(NSString*)key;

@end
