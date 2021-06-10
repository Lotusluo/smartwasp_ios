//
//  NormalToolbar.m
//  smartwasp
//
//  Created by luotao on 2021/6/10.
//

#import "NormalToolbar.h"
#import "AppDelegate.h"

@interface NormalToolbar()

@property (strong, nonatomic) IBOutlet UILabel *txtView;

@end

@implementation NormalToolbar

-(void) awakeFromNib{
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
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)nextResponder;
            [vc.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
}

-(void) setTitle:(NSString *)title{
    self.txtView.text = title;
}

@end
