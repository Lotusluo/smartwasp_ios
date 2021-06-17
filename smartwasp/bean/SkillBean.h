//
//  SkillBean.h
//  smartwasp
//
//  Created by luotao on 2021/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkillBean : NSObject

@property(nonatomic) NSInteger skillId;
@property(nonatomic,strong)NSString *skillName;
@property(nonatomic,strong)NSString *shopName;
@property(nonatomic)NSInteger *proId;
@property(nonatomic,strong)NSString *icon;
@property(nonatomic)BOOL isBuy;
@property(nonatomic,strong)NSString *expireTime;
@property(nonatomic,strong)NSString *skillDesc;
@property(nonatomic,strong)NSString *developer;
@property(nonatomic,strong)NSString *version;
@property(nonatomic,strong)NSString *updateTime;
@property(nonatomic,strong)NSArray<NSString*> *hitTextS;

@end

NS_ASSUME_NONNULL_END
