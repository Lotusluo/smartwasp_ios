//
//  GroupView.h
//  smartwasp
//
//  Created by luotao on 2021/6/2.
//

#import <UIKit/UIKit.h>
#import "GroupBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupView : UIView

//组数据
@property(nonatomic,strong,nonnull) GroupBean *groupBean;

-(CGFloat) uiHeight;

//静态生成
+(GroupView*)newView;

@end

NS_ASSUME_NONNULL_END
