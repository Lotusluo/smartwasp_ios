//
//  NetDAO.h
//  smartwasp
//
//  Created by luotao on 2021/5/12.
//

#import <Foundation/Foundation.h>
#import "BaseBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetDAO : NSObject

+ (NetDAO*)sharedInstance;

-(void)post:(NSDictionary*) params path:(NSString*) path callBack:(void(^)(BaseBean* cData)) complete;

@end

NS_ASSUME_NONNULL_END
