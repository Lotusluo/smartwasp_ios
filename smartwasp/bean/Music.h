//
//  music.h
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Music : NSObject

//是否有音乐畅听
@property(nonatomic) Boolean enable;

//redirect_url
@property(nonatomic,strong) NSString *redirect_url;

//text
@property(nonatomic,strong) NSString *text;

@end

NS_ASSUME_NONNULL_END
