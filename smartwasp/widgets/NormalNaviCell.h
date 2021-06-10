//
//  NormalNaviCell.h
//  smartwasp
//
//  Created by luotao on 2021/5/28.
//

#import <UIKit/UIKit.h>
#import "ISWDelegate.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface NormalNaviCell : UIView

//左侧图标
@property (nonatomic, strong)IBInspectable UIImage* leftIcon;

//按钮标题
@property (nonatomic, strong)IBInspectable NSString* title;

//右侧图标
@property (nonatomic, strong)IBInspectable UIImage* rightIcon;

//是否有底划线
@property IBInspectable BOOL hasBottomLine;

//代理
@property (nonatomic,weak) id<ISWClickDelegate> delegate;

@end


NS_ASSUME_NONNULL_END
