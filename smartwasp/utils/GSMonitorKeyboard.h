//
//  GSMonitorKeyboard.h
//  smartwasp
//
//  Created by luotao on 2021/6/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSMonitorKeyboard : NSObject

@property (nonatomic, assign) BOOL showKeyboard;
 
+(id)sharedMonitorMethod;
-(void)run;

@end

NS_ASSUME_NONNULL_END
