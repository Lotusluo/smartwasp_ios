//
//  SkillDetailViewController.h
//  smartwasp
//
//  Created by luotao on 2021/6/18.
//

#import <UIKit/UIKit.h>
#import "SkillBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkillDetailViewController : UIViewController

//技能数据
@property(nonatomic,strong)SkillBean* skillBean;

//静态生成ViewController
+(SkillDetailViewController *) createNewPage:(SkillBean *) skillBean;

@end


NS_ASSUME_NONNULL_END
