//
//  GSMonitorKeyboard.m
//  smartwasp
//
//  Created by luotao on 2021/6/19.
//

#import "GSMonitorKeyboard.h"

static GSMonitorKeyboard *sharedMonitor = nil;
 
@implementation GSMonitorKeyboard
 
+ (id)sharedMonitorMethod {
    @synchronized (self){
        if (!sharedMonitor) {
            sharedMonitor = [[GSMonitorKeyboard alloc] init];
        }
    }
    return sharedMonitor;
}

-(void)run{
    NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:sharedMonitor selector:@selector(keyboardDidShow) name:UIKeyboardWillShowNotification object:nil];
    [nf addObserver:sharedMonitor selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
    sharedMonitor.showKeyboard = NO;
}
 
// 键盘弹出
- (void)keyboardDidShow {
    _showKeyboard = YES;
}
 
// 键盘隐藏
- (void)keyboardDidHide {
    _showKeyboard = NO;
}

@end
