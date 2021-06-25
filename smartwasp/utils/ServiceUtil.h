//
//  ServiceUtil.h
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceUtil : NSObject

//获取当前连接的wifi信息
+(NSString*)wifiSsid;

@end

NS_ASSUME_NONNULL_END
