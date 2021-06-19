//
//  music.m
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import "MusicBean.h"

@implementation MusicBean


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"enable" : @[@"enable",@"music_enable"]};
}


@end
