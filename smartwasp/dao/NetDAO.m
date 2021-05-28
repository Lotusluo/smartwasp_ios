//
//  NetDAO.m
//  smartwasp
//
//  Created by luotao on 2021/5/12.
//


#import "NetDAO.h"
#import <AFNetworking.h>
#import "NSObject+YYModel.h"

@interface NetDAO()
//AFNET请求管理器
@property(nonatomic,strong) AFHTTPSessionManager* afManager;

@end

@implementation NetDAO

//服务器地址
static NSString*  BASE_URL = @"https://box.smartwasp.com.cn:8082/";
static NSString* access_token = @"smartwasp-eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiIxMTQiLCJzdWIiOiJ4aGYtdXNlciIsImlhdCI6MTYxNTAyNDc1NSwiaXNzIjoiY3hnIiwiYXV0aG9yaXRpZXMiOiJbe1wiYXV0aG9yaXR5XCI6XCJST0xFX3hoZi11c2VyXCJ9XSIsInR5cGUiOiJ1c2VyIiwiZXhwIjoyNDc5MDI0NzU2fQ.EDE85l8pgVc3K6viWFWChwBt74P246tmX3BHUhb12O1wR-dskEL4h9nrCxp2E9zN41eeRRHwc49gAv-vzBJN1w";

//服务器请求单例模式
static NetDAO *sharedSingleton = nil;

//获取单例模式
+ (NetDAO *)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
        [sharedSingleton initConfig];
    });
    return sharedSingleton;
}

//初始化网络请求配置
-(void)initConfig{
    _afManager = [AFHTTPSessionManager manager];
    [_afManager.requestSerializer setValue:access_token forHTTPHeaderField:@"access_token"];
    [_afManager.requestSerializer setValue:@"no-cache, max-age=0" forHTTPHeaderField:@"Cache-Control"];
}

//post请求
-(void)post:(NSDictionary*) params path:(NSString*) path callBack:(void(^)(BaseBean* cData)) complete{
    NSString* api = [BASE_URL stringByAppendingString:path];
    [_afManager POST:api parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BaseBean *okBean = [BaseBean yy_modelWithJSON:responseObject];
        complete(okBean);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

@end
