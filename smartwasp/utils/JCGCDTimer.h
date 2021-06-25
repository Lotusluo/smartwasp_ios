//
//  JCGCDTimer.h
//  smartwasp
//
//  Created by tao luo on 2021/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JCGCDTimer : NSObject

+ (NSString*)timerTask:(void(^)(void))task
            start:(NSTimeInterval) start
         interval:(NSTimeInterval) interval
          repeats:(BOOL) repeats
             async:(BOOL)async;

+(void)canelTimer:(NSString*)timerName;

@end

NS_ASSUME_NONNULL_END
