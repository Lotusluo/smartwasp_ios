//
//  Banner.h
//  smartwasp
//
//  Created by luotao on 2021/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerBean : NSObject

//id
@property(nonatomic) int _id;

//banner图标
@property(nonatomic,strong) NSString *image;

//banner链接
@property(nonatomic,strong)NSString *url;

@end

NS_ASSUME_NONNULL_END
