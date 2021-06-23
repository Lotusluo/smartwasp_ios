//
//  MusicStateBean.m
//  smartwasp
//
//  Created by luotao on 2021/6/21.
//

#import "MusicStateBean.h"

@implementation MusicStateBean

-(BOOL)isPlaying{
    if(!self.music_player)
        return NO;
    return self.music_player.playing;
}

@end
