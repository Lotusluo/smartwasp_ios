//
//  iflyosQuietSDKForiOS.h
//  iflyosQuietSDKForiOS
//
//  Created by 周经伟 on 2019/6/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iflyosQuietSDKForiOS : NSObject
/**
 *  单例
 */
+(iflyosQuietSDKForiOS *) shareInstance;
/**
 *  声波配网
 *  ssid : wifi名
 *  password : 密码
 *  isAuth : 是否进行授权（YES：配网+授权，NO：配网）
 */
-(void) sendQuiet:(NSString *) ssid password:(NSString *) password isAuth:(BOOL) isAuth;
@end
