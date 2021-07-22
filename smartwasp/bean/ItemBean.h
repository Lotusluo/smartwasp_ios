//
//  ItemBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItemBean : NSObject

@property(nonatomic,strong) NSString *from;
@property(nonatomic,strong) NSString *_id;
@property(nonatomic,strong) NSString *image;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *category_name;

@end

NS_ASSUME_NONNULL_END
