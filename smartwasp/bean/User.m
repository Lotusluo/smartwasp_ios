//
//  User.m
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import "User.h"


@implementation User

//采用传统方式序列化
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.user_id forKey:@"userId"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeInt:self.is_vip forKey:@"isVip"];
}

//采用传统方式反序列化
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.user_id = [aDecoder decodeObjectForKey:@"userId"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.is_vip = [aDecoder decodeIntForKey:@"isVip"] == 1;
    }
    return self;
}

@end
