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


//获取单例模式
+ (NetDAO *)sharedInstance {
    static NetDAO *sharedSingleton = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
    });
    return sharedSingleton;
}

//初始化网络请求配置
-(AFHTTPSessionManager*)afManager{
    if(!_afManager){
        _afManager = [AFHTTPSessionManager manager];
        [_afManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _afManager.requestSerializer.timeoutInterval = 15;
        [_afManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [_afManager.requestSerializer setValue:access_token forHTTPHeaderField:@"access_token"];
        [_afManager.requestSerializer setValue:@"no-cache, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    }
    return _afManager;
}


//post请求
-(void)post:(NSDictionary*) params path:(NSString*) path callBack:(void(^)(BaseBean<id>* cData)) complete{
    NSString* api = [BASE_URL stringByAppendingString:path];
    [self.afManager POST:api parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(responseObject){
            NSLog(@"responseObject:%@",responseObject);
            BaseBean<id> *bean = [BaseBean<id> yy_modelWithJSON:responseObject];
            complete(bean);
        }else{
            BaseBean *emptyBean = BaseBean.new;
            emptyBean.errCode = -1;
            complete(emptyBean);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BaseBean *errorBean = BaseBean.new;
        errorBean.errCode = -2;
        complete(errorBean);
    }];
}

@end
