//
//  ItemMoreViewController.h
//  smartwasp
//
//  Created by luotao on 2021/7/21.
//

#import <UIKit/UIKit.h>
#import "GroupBean.h"
#import "ItemBean.h"
#import "JXCategoryListContainerView.h"
#import "JXCategoryView.h"
#import "NotifyViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItemMoreViewController : NotifyViewController<JXCategoryListContainerViewDelegate>

@property(nonatomic,strong)NSArray<ItemBean*> *items;
@property (strong,nonatomic)NSMutableDictionary *map;
@property(nonatomic,strong)GroupBean *groupBean;

//指示器
@property (weak, nonatomic) IBOutlet JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

//静态构造
+(ItemMoreViewController *) createNewPage:(NSArray<ItemBean*> *) items group:(GroupBean *) groupBean;

@end

NS_ASSUME_NONNULL_END
