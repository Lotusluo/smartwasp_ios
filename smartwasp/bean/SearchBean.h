//
//  SearchBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/30.
//

#import <Foundation/Foundation.h>
#import "SongBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchBean : NSObject

@property(nonatomic)NSInteger total;
@property(nonatomic)NSInteger page;
@property(nonatomic)NSInteger limit;
@property(nonatomic,strong) NSArray<SongBean*>  *results;

@end

NS_ASSUME_NONNULL_END
