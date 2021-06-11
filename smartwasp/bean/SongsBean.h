//
//  SongsBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/11.
//

@class SongBean;

#import <Foundation/Foundation.h>
#import "SongBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongsBean : NSObject

@property(nonatomic,strong) NSString *from;
@property(nonatomic,strong) NSString *from_type;
@property(nonatomic,strong) NSString *image;
@property(nonatomic,strong) NSArray<SongBean*>  *items;

@end

NS_ASSUME_NONNULL_END
