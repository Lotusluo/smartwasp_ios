//
//  IFLYNSString+SBJSONParsing.h
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IFLYOSNSString_SBJSONParsing)
+(NSString *) randomString;
/**
 *  根据原字符串替的目标字符串换成需要替换的字符串
 *  origStr : 原字符串
 *  targetStr : 目标字符串
 *  replaceStr : 需要替换的字符串
 *  return : 替换后的字符串
 */
+(NSString *) stringSubstitution:(NSString *) origStr targetStr:(NSString *)targetStr replaceStr:(NSString *) replaceStr;
/**
 *  根据名字从URL取value
 */
+ (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url;
- (NSString*) sha256ForIOS13;
- (NSString *)SHA256;

- (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key;

-(NSDictionary *) JSONStringWithDictionary;
-(NSArray *) JSONStringWithArray;

//解析BLE 蓝牙ad信息(厂商标识)
-(NSString *) getBLEAdvertFactoryFlag;
//解析BLE 蓝牙ad信息（clientId）
-(NSString *) getBLEAdvertClientId;
@end
