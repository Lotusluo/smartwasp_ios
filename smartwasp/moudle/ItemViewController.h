//
//  ItemViewController.h
//  smartwasp
//
//  Created by luotao on 2021/6/10.
//

#import <UIKit/UIKit.h>
#import "ItemBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItemViewController : UIViewController

+(ItemViewController *) createNewPage:(ItemBean *) bean;

@end

@interface EGOScrollView: UIScrollView <UIGestureRecognizerDelegate>

@end

NS_ASSUME_NONNULL_END
