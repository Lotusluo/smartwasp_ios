//
//  NormalToolbar.m
//  smartwasp
//
//  Created by luotao on 2021/6/10.
//

#import "NormalToolbar.h"
#import "AppDelegate.h"
#import "UIViewHelper.h"
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface NormalToolbar()

@end

@implementation NormalToolbar

-(void)awakeFromNib{
    [super awakeFromNib];
    UIView *baseView = [[[NSBundle mainBundle] loadNibNamed:@"NormalToolbar" owner:self options:nil] lastObject];
    baseView.frame = self.bounds;
    [self addSubview:baseView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)onPressback:(id)sender {
    [APPDELEGATE.rootNavC popViewControllerAnimated:YES];
}

-(void)setTitle:(NSString *)title{
    self.txtView.text = title;
}

-(void)setTitleColor:(UIColor *)titleColor{
    self.txtView.textColor = titleColor;
}

@end
