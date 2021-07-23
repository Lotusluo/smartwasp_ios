//
//  SkillBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkillBean : NSObject

//技能ID
@property(nonatomic) int _id;
//技能名称
@property(nonatomic,strong)NSString *skillName;
//技能图标
@property(nonatomic,strong)NSString *icon;
//技能描述
@property(nonatomic,strong)NSString *skillDesc;
//技能开发者
@property(nonatomic,strong)NSString *developer;
//技能版本
@property(nonatomic,strong)NSString *version;
//更新时间
@property(nonatomic,strong)NSString *updateTime;
//示范语句
@property(nonatomic,strong)NSArray<NSString*> *hitTextS;
//类别
@property(nonatomic,strong)NSString *category_name;

@end

NS_ASSUME_NONNULL_END
