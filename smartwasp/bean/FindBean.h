//
//  FindBean.h
//  smartwasp
//
//  Created by luotao on 2021/5/31.
//
@class Banner,GroupBean;

#import <Foundation/Foundation.h>
#import "BannerBean.h"
#import "GroupBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface FindBean : NSObject

//发现页导航图片
@property(nonatomic,strong) NSArray<BannerBean*>  *banners;

//音源组
@property(nonatomic,strong) NSArray<GroupBean*>  *groups;

@end

NS_ASSUME_NONNULL_END
