//
//  CommonTabController.h
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import <UIKit/UIKit.h>
#import "BaseTabViewController.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonTabController : BaseTabViewController

//通用VC的类别
@property(nonatomic) URL_PATH_ENUM  vcType;
@property(nonatomic,strong)NSString *tag;


@end

NS_ASSUME_NONNULL_END
