//
//  BaseBean.m
//  smartwasp
//
//  Created by luotao on 2021/5/12.
//

#import "BaseBean.h"

@implementation BaseBean

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"errCode" : @[@"errCode",@"code"],
        @"errMsg" : @[@"errMsg",@"msg"]};
}

@end
