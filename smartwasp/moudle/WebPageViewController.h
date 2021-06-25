//
//  NewPageViewController.h
//  iflyosSDKDemo
//
//  Created by admin on 2018/9/10.
//  Copyright © 2018年 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFLYOSSDK.h"

@interface WebPageViewController : UIViewController

@property(nonatomic)Boolean isInterupt;

@property(nonatomic)BOOL disappearHideBar;

@property(copy,nonatomic)NSString *contextTag;
+(WebPageViewController *)createNewPageWithTag:(NSString *) tag;

@property(copy,nonatomic)NSString *openUrl;
+(WebPageViewController *)createNewPageWithUrl:(NSString *) url;

@property(nonatomic)URL_PATH_ENUM path;
+(WebPageViewController *)createNewPageWithPath:(URL_PATH_ENUM) path;

@property(copy,nonatomic)NSString *authUrl;
+(WebPageViewController *)createNewPageWithAuth:(NSString *) url;
@end
