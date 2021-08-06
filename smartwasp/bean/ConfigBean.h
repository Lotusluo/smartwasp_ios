//
//  ConfigBean.h
//  smartwasp
//
//  Created by luotao on 2021/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigBean : NSObject


@property(nonatomic,strong)NSString *appMainTip;
@property(nonatomic,strong)NSString *appNoPayTip;
@property(nonatomic)NSInteger appValue;

@end

NS_ASSUME_NONNULL_END
