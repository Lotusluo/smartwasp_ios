//
//  SkillBean.m
//  smartwasp
//
//  Created by luotao on 2021/6/17.
//

#import "SkillBean.h"

@implementation SkillBean

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"hitTextS" : [NSString class]};
}

@end
