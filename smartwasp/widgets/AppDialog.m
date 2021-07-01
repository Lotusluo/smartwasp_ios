//
//  AppDialog.m
//  smartwasp
//
//  Created by luotao on 2021/6/15.
//

#import "AppDialog.h"
#import "AppDelegate.h"
#import "UIView+Extension.h"
#import <Masonry.h>
@interface AppDialog()<CAAnimationDelegate>
@end

@implementation AppDialog
//静态生成音乐播放弹出框
+(AppDialog*) createDialog:(NSString*) nib
              heightParam:(CGFloat) heightParam{
    AppDialog *appDialog = AppDialog.new;
    appDialog.backgroundColor = [UIColor whiteColor];
    appDialog.baseView = [[[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil] lastObject];
    appDialog.mask = UIView.new;
    appDialog.heightParam = heightParam;
    return appDialog;
}

//呈现
-(void)show{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.mask.frame = keyWindow.screen.bounds;
    [keyWindow addSubview:self.mask];
    [keyWindow addSubview:self];
}

//设置填充控件
-(void)setBaseView:(UIView *)baseView{
    _baseView = baseView;
    UIView *cancel = [self.baseView viewWithTag:-1000];
    if(cancel && [cancel isKindOfClass:UIButton.class]){
        [((UIButton *)cancel) addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:baseView];
}

//设置mask
-(void)setMask:(UIView *)mask{
    _mask = mask;
    self.mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    UITapGestureRecognizer *click=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    [mask addGestureRecognizer:click];
}

-(void)dismiss{
    [self dismiss:nil];
}

-(void)dismiss:(id)sender{
    [self doFadeIn:NO];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.baseView.frame = self.bounds;
    CGFloat safeBottom = sgm_safeAreaInset(self).bottom;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.superview);
        make.height.mas_equalTo(self.heightParam + safeBottom);
        make.bottom.equalTo(self.superview);
    }];
    [self acs_radiusWithRadius:10 corner:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self doFadeIn:YES];
}

//弹出框动画效果
-(void) doFadeIn:(Boolean) flag{
    [self.layer removeAllAnimations];
    CABasicAnimation *transAnimation  = [CABasicAnimation animationWithKeyPath:@"position"];
    if(!flag){
        transAnimation.delegate = self;
    }
    CGPoint fromValue = self.layer.position;
    CGPoint toValue = self.layer.position;
    if(flag){
        fromValue.y += self.frame.size.height;
    }else{
        toValue.y += self.frame.size.height;
    }
    transAnimation.fromValue =  [NSValue valueWithCGPoint: fromValue];
    transAnimation.toValue = [NSValue valueWithCGPoint:toValue];
    transAnimation.duration = 0.2;
    transAnimation.removedOnCompletion = NO;
    transAnimation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:transAnimation forKey:@"position"];
    
    //透明度变化
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:flag ? 0 : 1];
    opacityAnimation.toValue = [NSNumber numberWithFloat:flag ? 1 : 0];
    opacityAnimation.duration = 0.22;
    transAnimation.removedOnCompletion = NO;
    [self.mask.layer addAnimation:opacityAnimation forKey:@"opacity"];
}

#pragma mark --CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self removeFromSuperview];
    if(self.mask){
        [self.mask.layer removeAllAnimations];
        [self.mask removeFromSuperview];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
