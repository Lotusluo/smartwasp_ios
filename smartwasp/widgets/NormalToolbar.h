//
//  NormalToolbar.h
//  smartwasp
//
//  Created by luotao on 2021/6/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NormalToolbar : UIView

//标题
@property(nonatomic,strong) NSString *title;

//返回按钮颜色
@property(nonatomic,strong) UIColor *titleColor;

//标题控件
@property (strong, nonatomic) IBOutlet UILabel *txtView;

@end

NS_ASSUME_NONNULL_END
