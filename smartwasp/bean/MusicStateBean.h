//
//  MusicStateBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/21.
//

#import <Foundation/Foundation.h>
#import "MusicPlayerBean.h"
#import "SongBean.h"
#import "SpeakerBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicStateBean : NSObject

@property(nonatomic,strong)MusicPlayerBean *music_player;
@property(nonatomic,strong)SongBean *music;
@property(nonatomic,strong)NSString *device_id;
@property(nonatomic,strong)SpeakerBean *speaker;

//是否音乐播放中
-(BOOL) isPlaying;

@end

NS_ASSUME_NONNULL_END
