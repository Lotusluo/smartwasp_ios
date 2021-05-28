#import "PageControl2.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"

@interface PageControl2()

@property(nonatomic,strong) UIImage *image;

@end

@implementation PageControl2

@synthesize image;

-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    image = [UIImage imageNamed:@"icon_add"];
    return self;
}

-(void) setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    if (@available(iOS 14.0, *)) {
        if(self.tag != 1){
            self.tag = 1;
            [self setIndicatorImage:image forPage:0];
        }
    } else {
        [self updateDots];
    }
}


// 改变图片和大小
- (void)updateDots {
    if(self.subviews.count > 0){
        UIView *view = [self.subviews objectAtIndex: 0];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *dot = [self imageViewForSubview:view];
        dot.backgroundColor = [UIColor clearColor];
        dot.image = image;
        dot.transform = CGAffineTransformMakeScale(2, 2);
        dot.tintColor = self.currentPage == 0 ? [UIColor colorWithHexString:@"#f6921e"] : [UIColor lightGrayColor];
    }
}

//获取IOS14以下PCV
- (UIImageView *)imageViewForSubview:(UIView *) view {
    UIImageView * dot = nil;
    if ([view isKindOfClass: [UIView class]]) {
        for (UIView* subview in view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView *)subview;
                break;
            }
        }
        if (dot == nil) {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:dot];
        }
    }else {
        dot = (UIImageView *) view;
    }
    return dot;
}

@end
