//
//  UIColor+Extension.h
//  smartwasp
//
//  Created by luotao on 2021/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage ()

- (UIImage *)renderImageWithColor:(UIColor *)color;

- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur withTintColor:(UIColor *)tintColor;

+(UIImage*)imageBlurImage:(UIImage *)image WithBlurNumber:(CGFloat)blur;

@end

NS_ASSUME_NONNULL_END
