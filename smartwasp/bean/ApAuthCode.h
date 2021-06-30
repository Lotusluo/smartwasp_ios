//
//  ApAuthCode.h
//  smartwasp
//
//  Created by luotao on 2021/6/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApAuthCode : NSObject

@property(nonatomic,strong)NSString *auth_code;
@property(nonatomic,assign)NSInteger created_at;
@property(nonatomic,assign)NSInteger expires_in;
@property(nonatomic,assign)NSInteger interval;

@end

NS_ASSUME_NONNULL_END
