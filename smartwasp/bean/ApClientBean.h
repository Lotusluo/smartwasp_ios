//
//  ApClientBean.h
//  smartwasp
//
//  Created by luotao on 2021/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApClientBean : NSObject

//无屏音箱的clientID
@property(nonatomic,strong) NSString *clientID;

//图标路径（本地）
@property(nonatomic,strong) NSString *iconPath;

@end

NS_ASSUME_NONNULL_END
