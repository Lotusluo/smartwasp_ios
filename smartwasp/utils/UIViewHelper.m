//
//  UIViewHelper.m
//  smartwasp
//
//  Created by luotao on 2021/6/18.
//

#import "UIViewHelper.h"

@implementation UIViewHelper

//通过Nib名称获取UIView
+(UIView*)loadNibByName:(NSString*)name{
    return [[[NSBundle mainBundle] loadNibNamed:@"SkillView" owner:nil options:nil] lastObject];
}

//赋值
+(BOOL)attachText:(NSString*)text widget:(UIView*)widget{
    NSString *fun=@"setText:";
    SEL funSelector=NSSelectorFromString(fun);
    if([widget respondsToSelector:funSelector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [widget performSelector:funSelector withObject:text];
#pragma clang diagnostic pop
        return YES;
    }
    return NO;
}

//添加点击事件
+(void)attachClick:(UIView*)view target:(nullable id)target action:(nullable SEL)action{
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [view addGestureRecognizer:tap];
}

//获取当前附着的VC
+(UIViewController*)getAttachController:(UIView*)view{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)nextResponder;
            return vc;
        }
    }
    return nil;
}

+(void)showAlert:(NSString *)title message:(NSString *)msg target:(UIViewController *)target{
    [self showAlert:title message:msg target:target callBack:nil];
}

+(void)showAlert:(NSString *)title message:(NSString *)msg target:(UIViewController *)target callBack:(void(^ _Nonnull)(void)) callback{
    if ([msg isKindOfClass:[NSDictionary class]]) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg options:NSJSONWritingPrettyPrinted error:&parseError];
        msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    alertView.title = title;
    alertView.message = msg;
    [alertView addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(callback){
            callback();
        }
    }]];
    [target presentViewController:alertView animated:YES completion:^{
        
    }];
}

@end
