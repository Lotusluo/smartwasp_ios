//
//  UIView+UIView_alertView.m
//  iflyosSDKDemo
//
//  Created by admin on 2019/2/14.
//  Copyright © 2019年 test. All rights reserved.
//

#import "UIView+UIView_alertView.h"

@implementation UIView (UIView_alertView)
+(void) showAlert:(NSString *) title message:(NSString *) msg target:(UIViewController *) target{
    if ([msg isKindOfClass:[NSDictionary class]]) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg options:NSJSONWritingPrettyPrinted error:&parseError];
        msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    alertView.title = title;
    alertView.message = msg;
    [alertView addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil]];
    [target presentViewController:alertView animated:YES completion:^{
        
    }];
}
@end
