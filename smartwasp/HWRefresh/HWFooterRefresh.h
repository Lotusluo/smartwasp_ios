//
//  HWFooterRefresh.h
//  Demo
//
//  Created by Howe on 16/2/24.
//  Copyright © 2016年 Howe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWValue.h"

@interface HWFooterRefresh : UIView

- (void)hw_addFooterRefreshWithView:(__kindof UIScrollView * _Nonnull)scrollView hw_footerRefreshBlock:(HWRefreshBlock _Nonnull)block;

- (void)hw_endRefreshState;

- (void)hw_toRfreshState;

@end
