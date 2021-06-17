//
//  AppDialog.h
//  smartwasp
//
//  Created by luotao on 2021/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDialog : UIView

//填充的内容
@property(nonatomic,strong)UIView *baseView;

//mask
@property(strong,nonatomic) UIView *mask;

//动态获取高度方法
@property (strong,nonatomic) CGFloat (^heightFun)(void);

//呈现
-(void)show;

//创建dialog
+(AppDialog*) createDialog:(NSString*) nib
              heightParams:(CGFloat (^)(void)) heightFun;

@end

NS_ASSUME_NONNULL_END
