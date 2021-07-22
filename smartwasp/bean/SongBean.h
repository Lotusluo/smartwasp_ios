//
//  SongBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SongBean : NSObject

@property(nonatomic,strong) NSString *album_id;
@property(nonatomic,strong) NSString *artist;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *image;
@property(nonatomic,strong) NSString *_id;
@property(nonatomic,strong) NSString *source_type;
@property(nonatomic,strong) NSString *source;

@end

NS_ASSUME_NONNULL_END
