//
//  FindBean.m
//  smartwasp
//
//  Created by luotao on 2021/5/31.
//

#import <Foundation/Foundation.h>
#import "FindBean.h"
#import "Banner.h"

@implementation FindBean

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"banners" : [Banner class],
                    @"groups" : [GroupBean class]};
}

@end
