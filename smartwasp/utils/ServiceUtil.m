//
//  ServiceUtil.m
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import "ServiceUtil.h"

@implementation ServiceUtil

//获取当前连接的wifi信息
+(NSString*)wifiSsid{
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for(NSString *ifname in ifs){
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if(info && [info count]){
            break;
        }
    }
    NSString *strSsid =  info[@"SSID"];
    NSString *strBssid = info[@"BSSID"];
    return strSsid;
}

@end
