//
//  NewPageViewController.h
//  iflyosSDKDemo
//
//  Created by admin on 2018/9/10.
//  Copyright © 2018年 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPageViewController : UIViewController
@property (copy,nonatomic) NSString *contextTag;
@property (copy,nonatomic) NSString *openUrl;
@property (nonatomic) Boolean isInterupt;
+(NewPageViewController *) createNewPage:(NSString *) tag;
+(NewPageViewController *) createNewPage1:(NSString *) url;
@end
