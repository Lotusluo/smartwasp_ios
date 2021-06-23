//
//  Device.m
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import "DeviceBean.h"

@implementation DeviceBean

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
  
}

//设备是否在线
- (Boolean) isOnLine{
    if([self.status isEqualToString:@"online"]){
        return true;
    }
    return false;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"music" : @[@"music",@"music_access"],
        @"status" : @[@"status",@"state"]
    };
}

//
//return [NSString stringWithFormat:@"%@", num >= 10000 ? [NSString stringWithFormat:@"%0.1f万", (num / 10000.0)] : [NSString stringWithFormat:@"%zd",num]];
//-(void)setValue:(id)value forKey:(NSString *)key{
//    if([key isEqualToString:@"music"] || [key isEqualToString:@"music_access"]){
//        MusicBean *temp = [MusicBean new];
//        [temp setValuesForKeysWithDictionary:value];
//        self.music = temp;
//        return;
//    }
//    [super setValue:value forKey:key];
//}

//比较两个设备是否相等
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    DeviceBean *otherDev = (DeviceBean*) other;
    return [self.device_id isEqualToString:otherDev.device_id];
}

@end
