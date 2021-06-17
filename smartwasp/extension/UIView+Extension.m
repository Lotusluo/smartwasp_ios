#import "UIView+Extension.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark - RITLBorderLayer
@interface RITLBorderLayer: CALayer

/// 默认为0.0
@property (nonatomic, assign)CGFloat ritl_borderWidth;
/// 默认为UIEdgeInsetsZero
@property (nonatomic, assign)UIEdgeInsets ritl_borderInset;

@end

@implementation RITLBorderLayer

- (instancetype)init
{
    if (self = [super init]) {
        
        self.anchorPoint = CGPointZero;
        self.ritl_borderWidth = 0.0;
        self.ritl_borderInset = UIEdgeInsetsZero;
    }
    
    return self;
}

@end


#pragma mark - <RITLViewBorderDirection>

@protocol RITLViewBorderDirection <NSObject>

@property (nonatomic, strong) RITLBorderLayer *leftLayer;
@property (nonatomic, strong) RITLBorderLayer *topLayer;
@property (nonatomic, strong) RITLBorderLayer *rightLayer;
@property (nonatomic, strong) RITLBorderLayer *bottomLayer;

@end

#pragma mark - UIView<RITLViewBorderDirection>
@interface UIView (RITLViewBorderDirection)<RITLViewBorderDirection>
@end



@implementation UIView (Extension)

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}


-(void)setCornerRadius:(CGFloat)cornerRadius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}
-(void)setBorderColor:(UIColor *)borderColor{
    self.layer.borderColor = borderColor.CGColor;
}
-(void)setBorderWidth:(CGFloat)borderWidth{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)cornerRadius{
    return self.layer.cornerRadius;
}
- (CGFloat)borderWidth{
    return self.layer.borderWidth;
}
- (UIColor *)borderColor{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}


/**
 圆角
 使用自动布局，需要在layoutsubviews 中使用
 @param radius 圆角尺寸
 @param corner 圆角位置
 */
- (void)acs_radiusWithRadius:(CGFloat)radius corner:(UIRectCorner)corner {
    self.layer.masksToBounds = YES;
    if (@available(iOS 11.0, *)) {
        self.layer.cornerRadius = radius;
        self.layer.maskedCorners = (CACornerMask)corner;
    } else {
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
    }
}


@end
