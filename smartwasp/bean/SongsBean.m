//
//  SongsBean.m
//  smartwasp
//
//  Created by luotao on 2021/6/11.
//

#import "SongsBean.h"
#import "SongBean.h"

@implementation SongsBean

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"items" : [SongBean class]};
}

@end
