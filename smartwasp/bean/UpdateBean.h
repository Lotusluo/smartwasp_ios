//
//  UpdateBean.h
//  smartwasp
//
//  Created by luotao on 2021/7/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UpdateBean : NSObject

@property(nonatomic)NSInteger versionCode;
@property(nonatomic,strong)NSString *versionName;

@end

NS_ASSUME_NONNULL_END
