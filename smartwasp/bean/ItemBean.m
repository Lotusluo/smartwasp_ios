//
//  ItemBean.m
//  smartwasp
//
//  Created by luotao on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "ItemBean.h"

@implementation ItemBean

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"_id" : @[@"id"]};
}

@end
