//
//  Device.m
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import "Device.h"

@implementation Device

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
  
}

//设备是否在线
- (Boolean) isOnLine{
    if([self.status isEqualToString:@"online"]){
        return true;
    }
    return false;
}
//
//return [NSString stringWithFormat:@"%@", num >= 10000 ? [NSString stringWithFormat:@"%0.1f万", (num / 10000.0)] : [NSString stringWithFormat:@"%zd",num]];



//比较两个设备是否相等
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    Device *otherDev = (Device*) other;
    return [self.device_id isEqualToString:otherDev.device_id];
}

@end
