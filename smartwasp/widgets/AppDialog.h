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

//弹出框高度
@property (nonatomic) CGFloat heightParam;

//呈现
-(void)show;

-(void)dismiss;

//创建dialog
+(AppDialog*) createDialog:(NSString*) nib
              heightParam:(CGFloat) heightParam;

@end

NS_ASSUME_NONNULL_END
