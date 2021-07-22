//
//  GroupView.h
//  smartwasp
//
//  Created by luotao on 2021/6/2.
//

#import <UIKit/UIKit.h>
#import "GroupBean.h"
#import "ItemBean.h"

NS_ASSUME_NONNULL_BEGIN

@class GroupView;

@protocol ISelectedDelegate <NSObject>

@optional

-(void)groupView:(GroupView *)groupView canClickItemAtIndex:(ItemBean *)bean;

-(void)groupView:(GroupView *)groupView onClickMore:(GroupBean *)bean;

@end


@interface GroupView : UIView

//组数据
@property(nonatomic,strong,nonnull) GroupBean *groupBean;

//item点击
@property(nonatomic,strong) id<ISelectedDelegate>  delegate;

//获取动态高度
-(CGFloat) uiHeight;

//静态生成
+(GroupView*)newView;

@end

NS_ASSUME_NONNULL_END
