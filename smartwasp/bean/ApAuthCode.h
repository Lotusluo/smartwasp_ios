//
//  ApAuthCode.h
//  smartwasp
//
//  Created by luotao on 2021/6/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//"auth_code" = "WgGSRVANZZ-B4T7PzXQsGYtmVXqXU3YRK-417ZenDUDfScNarhJNVPObNyFmbmEs";
//"created_at" = 1626085051;
//"expires_in" = 600;
//interval = 2;

@interface ApAuthCode : NSObject

@property(nonatomic,strong)NSString *auth_code;
@property(nonatomic,assign)NSInteger created_at;
@property(nonatomic,assign)NSInteger created_at_local;
@property(nonatomic,assign)NSInteger expires_in;
@property(nonatomic,assign)NSInteger interval;

//授权码是否过期
-(BOOL)isOverdue;

@end

NS_ASSUME_NONNULL_END
