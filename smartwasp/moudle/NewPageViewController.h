//
//  NewPageViewController.h
//  iflyosSDKDemo
//
//  Created by admin on 2018/9/10.
//  Copyright © 2018年 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFLYOSSDK.h"

@interface NewPageViewController : UIViewController

@property (nonatomic) Boolean isInterupt;

@property (nonatomic) BOOL disappearHideBar;

@property (copy,nonatomic) NSString *contextTag;
+(NewPageViewController *) createNewPageWithTag:(NSString *) tag;

@property (copy,nonatomic) NSString *openUrl;
+(NewPageViewController *) createNewPageWithUrl:(NSString *) url;

@property(nonatomic) URL_PATH_ENUM  path;
+(NewPageViewController *) createNewPageWithpath:(URL_PATH_ENUM) path;
@end
