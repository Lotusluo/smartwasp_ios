//
//  CodingUtil.h
//  smartwasp
//
//  Created by luotao on 2021/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CodingUtil : NSObject

//二进制数据转Hex字符串
+(NSString*) hexStringFromData:(NSData*) data;

//hex字符串转二进制数据
+(NSData*) dataFromHexString:(NSString*)string;

@end

NS_ASSUME_NONNULL_END
