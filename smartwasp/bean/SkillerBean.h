//
//  FindBean.h
//  smartwasp
//
//  Created by luotao on 2021/5/31.
//
@class Banner,GroupBean;

#import <Foundation/Foundation.h>
#import "BannerBean.h"
//#import "GroupBean.h"
#import "SkillBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkillerBean : NSObject

//发现页导航图片
@property(nullable,nonatomic,strong) NSArray<BannerBean*>  *banners;

//技能组
@property(nullable,nonatomic,strong) NSArray<SkillBean*>  *skills;

//类别
@property(nullable,nonatomic,strong) NSArray *abbrs;
//类别数组
@property (strong,nonatomic)NSMutableDictionary *map;

@end

NS_ASSUME_NONNULL_END
