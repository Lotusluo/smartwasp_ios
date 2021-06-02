//
//  music.h
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicBean : NSObject

//Name       Typedef       Header        True Value    False Value
//BOOL       signedchar    objc.h        YES           NO
//bool       _Bool         stdbool.h     true          false
//Boolean    unsignedchar  MacTypes.h    TRUE          FALSE

//是否有音乐畅听
@property(nonatomic) bool enable;

//redirect_url
@property(nonatomic,strong) NSString *redirect_url;

//text
@property(nonatomic,strong) NSString *text;

@end

NS_ASSUME_NONNULL_END
