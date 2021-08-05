//
//  FindBean.m
//  smartwasp
//
//  Created by luotao on 2021/5/31.
//

#import <Foundation/Foundation.h>
#import "SkillerBean.h"


@implementation SkillerBean

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"banners" : [BannerBean class],
                    @"skills" : [SkillBean class]};
}

//获取类别数组
-(NSArray*) abbrs{
    if(!_abbrs){
        self.map = [NSMutableDictionary new];
        NSArray *temp = [self.skills valueForKeyPath:@"category_name"];
        //NSSet 有序化去重
        NSOrderedSet *orderNumSet = [NSOrderedSet orderedSetWithArray:temp];
        temp = orderNumSet.array;
        //无序去重
//        temp = [temp valueForKeyPath:@"@distinctUnionOfObjects.self"];
        for(NSString* key in temp){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.category_name contains[c] %@",key];
            NSArray *values = [self.skills filteredArrayUsingPredicate:predicate];
            self.map[key] = values;
        }
        _abbrs = temp;
    }
    return _abbrs;
}

@end
