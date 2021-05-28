//
//  User.h
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

//用户ID
@property(nonatomic,copy) NSString *user_id;
//用户注册号码
@property(nonatomic,copy) NSString *phone;
//是否是vip用户
@property(nonatomic) Boolean is_vip;

@end

NS_ASSUME_NONNULL_END
