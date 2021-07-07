//
//  StatusBean.m
//  smartwasp
//
//  Created by luotao on 2021/6/21.
//

#import "StatusBean.h"
#import "MusicStateBean.h"
#import "DeviceBean.h"
#import "NSObject+YYModel.h"

@implementation StatusBean

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    //对于OC泛型转换暂时没有研究
    if([self.type isEqualToString:@"music_state"]){
        //将data转换为MusicStateBean
        self.data = [MusicStateBean yy_modelWithDictionary:dic[@"data"]];
        return YES;
    }
    if([self.type isEqualToString:@"device_state"]){
        //将data转换为DeviceBean
        self.data = [DeviceBean yy_modelWithDictionary:dic[@"data"]];
        return YES;
    }
    return NO;
}

//比较时间戳
-(BOOL) isNewerThan:(StatusBean *) other{
    if(!other.timestamp)
        return NO;
    return [self.timestamp longLongValue] > [other.timestamp longLongValue];
}

@end
