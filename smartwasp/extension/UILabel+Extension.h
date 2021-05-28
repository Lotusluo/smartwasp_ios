//
//  UILabel+Extension.h
//  smartwasp
//
//  Created by luotao on 2021/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger,DrawableType){
    LEFT = 0,//默认
    TOP = 1 << 0,
    RIGHT = 2 << 0,
    BOTTOM = 3 <<0
};

@interface UILabel (Extension)

//设置文本icon
-(void) setDrawable: (UIImage*) image;

@end

NS_ASSUME_NONNULL_END
