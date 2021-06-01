//
//  GroupBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/1.
//

@class ItemBean;

#import <Foundation/Foundation.h>
#import "ItemBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupBean : NSObject

@property(nonatomic,strong) NSString *abbr;
@property(nonatomic) bool has_more;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *section_id;
@property(nonatomic,strong) NSArray<ItemBean*>  *items;

@end

NS_ASSUME_NONNULL_END
