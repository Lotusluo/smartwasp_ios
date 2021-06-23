//
//  UIView+UIView_alertView.h
//  iflyosSDKDemo
//
//  Created by admin on 2019/2/14.
//  Copyright © 2019年 test. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (UIView_alertView)
+(void) showAlert:(NSString *) title message:(NSString *) msg target:(UIViewController *) target;
@end

NS_ASSUME_NONNULL_END
