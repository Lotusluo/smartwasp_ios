//
//  BaseViewController.h
//  smartwasp
//
//  Created by luotao on 2021/7/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property(nonatomic,strong)NSString *mTitle;

-(void)pushViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
