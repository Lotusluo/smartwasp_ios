//
//  BaseBean.h
//  smartwasp
//
//  Created by luotao on 2021/5/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//__covariant修饰的T，表示当需要将子类转为父类的时候，如上面的b中的B类转为a中的A父类，也就允许将子类转为父类。
//__contravariant则是相反的意思，将泛型中的父类转为子类。
@interface BaseBean<T> : NSObject

//错误码
@property NSInteger errCode;

//错误信息
@property(nonatomic,strong) NSString* errMsg;

//数据
@property(nonatomic,strong) T data;

@end

NS_ASSUME_NONNULL_END
