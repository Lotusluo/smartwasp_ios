//
//  music.m
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import "MusicBean.h"

@implementation MusicBean

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if([key isEqualToString:@"music_enable"]){
        self.enable = value;
    }
}

@end
