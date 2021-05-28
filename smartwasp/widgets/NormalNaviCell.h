//
//  NormalNaviCell.h
//  smartwasp
//
//  Created by luotao on 2021/5/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface NormalNaviCell : UIView

//左侧图标
@property (nonatomic, assign)IBInspectable UIImage* leftIcon;

//按钮标题
@property (nonatomic, assign)IBInspectable NSString* title;

//右侧图标
@property (nonatomic, assign)IBInspectable UIImage* rightIcon;


@end

NS_ASSUME_NONNULL_END
