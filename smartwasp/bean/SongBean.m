//
//  SongBean.m
//  smartwasp
//
//  Created by luotao on 2021/6/11.
//

#import "SongBean.h"

@implementation SongBean

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"_id" : @[@"id"]};
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
  
}

@end
