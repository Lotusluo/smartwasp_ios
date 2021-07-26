//
//  ListViewController.h
//  JXCategoryView
//
//  Created by luotao on 2021/7/26.
//

#import <UIKit/UIKit.h>
#import "JXCategoryListContainerView.h"
#import "SkillBean.h"

@interface ListViewController : UITableViewController

@property(nonatomic,strong)NSArray<SkillBean*> *lists;

@end
