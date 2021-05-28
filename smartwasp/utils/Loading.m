//
//  LoadingUtils.m
//  smartwasp
//
//  Created by luotao on 2021/4/10.
//

#include "Loading.h"
#define window [UIApplication sharedApplication].delegate.window

@interface Loading ()

//弹出框消失回调
@property (strong, nonatomic) OnDismiss onDismiss;

@end

@implementation Loading

//全局唯一的加载控件
static Loading *loadingView = nil;

-(instancetype)initInstance:(OnDismiss)onDismiss{
    if (self = [super initWithFrame:window.frame]) {
        self.onDismiss = onDismiss;
        //生成一个等待框控件
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [indicatorView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        indicatorView.frame = CGRectInset([indicatorView frame], -15, -15);
        indicatorView.layer.cornerRadius = 5;
        indicatorView.center = self.center;
        [indicatorView startAnimating];
        [self addSubview:indicatorView];
        
        //设置取消手势
        UITapGestureRecognizer *tapRecognizer =[[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(foundTap:)];
        [self addGestureRecognizer:tapRecognizer];
        self.userInteractionEnabled = true;
    }
    
    return self;
}

//点击事件
- (void)foundTap:(id)sender {
    self.onDismiss();
    [Loading dismiss];
}

//生成一个加载控件
+(void)show:(OnDismiss)onDismiss{
    [self dismiss];
    loadingView = [[Loading alloc] initInstance:onDismiss];
    [window addSubview:loadingView];
}

//取消弹出框
+(void) dismiss{
    if(loadingView){
        //取消上一个加载控件
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
}

@end
