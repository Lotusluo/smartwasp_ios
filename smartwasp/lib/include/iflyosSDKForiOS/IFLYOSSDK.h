//
//  IFLYOSSDK.h
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "IFLYOSSDKDelegate.h"
#import "IFLYOSWKWebView+IFLYOSWebView.h"

/**
 *  web路径枚举
 */
typedef NS_ENUM (NSUInteger,URL_PATH_ENUM){
    SKILLS = 0,//语音技能
    ACCOUNTS = 1 << 0,//内容账号
    CLOCKS = 2 << 0,//我的闹钟
    CONTROLLED_DEVICES = 3 << 0,//被控设备
    PERSONAL_VOICE = 4 << 0,//音库
    WAKEUP_WORDS = 5 << 0,//唤醒词
    SLEEP = 6 << 0,//定时休眠
    SPEARER = 7 << 0,//发音人
    BLUETOOTH = 8 << 0,//蓝牙连接
    DEVICE_VERSION_UPDATE = 9 << 0,//版本升级
    TALK = 10 << 0, //对话
    IFTTT = 11 << 0 //IFTTT训练计划
};

typedef NS_ENUM (NSUInteger,LOGIN_TYPE){
    DEFAULT = 0,//默认
    CUSTOM = 1 << 0//第三方自定义
};

@class IFLYOSWebViewGenerator;
@interface IFLYOSSDK : NSObject
//是否停止BLE配网轮训
@property(assign) BOOL isStopBLEConfirmLoop;
/**
 *  单例
 */
+(IFLYOSSDK *) shareInstance;

/**
 *  初始化接口
 *  appId : open.iflyos.com申请的appid
 *  schema : schema 回调拉起
 *  loginType : 登陆类型（DEFAULT：默认，CUSTOM：第三方自定义）
 */
-(void) initAppId:(NSString *) appId schema:(NSString *)schema loginType:(LOGIN_TYPE)loginType;
/**
 *  检查Appid是否存在
 */
-(BOOL) checkAppId;

/**
 *  是否启动debug模式
 */
-(void) setDebugModel:(BOOL) debug;

/**
 *  设置自定义token
 */
-(BOOL) setCustomToken:(NSString *) token;

/**
 *  获取当前token
 */
-(NSString *) getToken;

/**
 *  根据tag获取webView;
 */
-(IFLYOSWebViewGenerator *) selectWebViewWithTag:(NSString *) tag;

/**
 *  target : 设置回调原生api接口代理
 */
-(void) setWebViewDelegate:(id) target tag:(NSString *)tag;
/**
 *  注册webView
 *  handler : 接口处理器
 *  tag : 标识符
 */
-(void) registerWebView:(WKWebView *) webView handler:(id) handler tag:(NSString *) tag;
/**
 *  注册webView
 *  handler : 接口处理器
 *  tag : 标识符
 *  contextTag : 上下文标识符
 */
-(void) registerWebView:(WKWebView *) webView handler:(id) handler tag:(NSString *) tag contextTag:(NSString *)contextTag;
/**
 *  注销webView
 */
-(void) unregisterWebView:(NSString *) tag;

/**
 *  注销全部webView
 */
-(void) unregisterAllWebView;

/**
 *  webView 出现时调用
 *  @param webViewTag    由 SDK 返回的 WebView 标识
 */
-(void) webViewAppear:(NSString *) webViewTag;

/**
 *  webView 消失时调用
 *  @param webViewTag    由 SDK 返回的 WebView 标识
 */
-(void) webViewDisappear:(NSString *) webViewTag;

/**
 *  IAP二次校验后调用
 *  @param webViewTag    由 SDK 返回的 WebView 标识
 *  status : 是否成功状态码（0:成功，1支付失败，2校验失败）
 */
-(void) IAPTranscation:(NSString *) webViewTag status:(NSInteger) status;

/**
 *  IAP二次校验后调用
 *  @param webViewTag    由 SDK 返回的 WebView 标识
 *  status : 是否成功状态码（0:成功，1支付失败，2校验失败）
 *  tradeNo : 订单号
 */
-(void) IAPTranscation:(NSString *) webViewTag status:(NSInteger) status tradeNo:(NSString *) tradeNo;

/**
 *  跳到酷狗应用会员页面
 */
-(BOOL) jumpKugouVIPPage:(NSString *) userId;

/**
 *  打开新页面
 *  tag : 标识符
 */
-(void) openNewPage:(NSString *) tag;

/**
 *  打开登录页
 */
-(void) openLogin:(NSString *)tag;

/**
 *  判断是否已登录
 */
-(BOOL) isLogin;

/**
 *  注销登录
 */
-(void) logout:(id<IFLYOSsdkLoginDelegate>) handler;

/**
 * 通过调用统一的唤起 Web 入口，传入不同的参数以调用不同的页面，
 * 此处调用任意页面都应在 Cookie 中携带 token.
 *
 * @param webViewTag    由 SDK 返回的 WebView 标识
 * @param pageIndex     由 SDK 定义可供传入的参数，非法参数终止调用并返回对应状态码.
 *
 *                      参数与指定路劲对应关系
 *                      IFlyHome.TALK               /talk
 *                      IFlyHome.SKILLS             /skills
 *                      IFlyHome.ACCOUNTS           /accounts
 *                      IFlyHome.CLOCKS             /clocks
 *                      IFlyHome.CONTROLLED_DEVICES /controlled-devices
 *  @return  result      meaning
 *          1           表示调用成功
 *          0           表示未初始化 appId
 *          -1          表示找不到可调用的 WebView
 *          -2          传入参数不合法
 *          -3          未登录
 */
-(NSInteger) openWebPage:(NSString *) webViewTag pageIndex:(URL_PATH_ENUM) pageIndex;


/**
 * 通过调用统一的唤起 Web 入口，传入不同的参数以调用不同的页面，
 * 此处调用任意页面都应在 Cookie 中携带 token.
 * type:xmly-喜马拉雅，kugou-酷狗
 *  @return  result      meaning
 *          1           表示调用成功
 *          0           表示未初始化 appId
 *          -1          表示找不到可调用的 WebView
 *          -2          传入参数不合法
 *          -3          未登录
 */
-(NSInteger) openWebPage:(NSString *) webViewTag type:(NSString *) type;

/**
 * 通过调用统一的唤起 Web 入口，传入不同的参数以调用不同的页面，
 * 此处调用任意页面都应在 Cookie 中携带 token.
 *
 * @param webViewTag    由 SDK 返回的 WebView 标识
 * @param pageIndex     由 SDK 定义可供传入的参数，非法参数终止调用并返回对应状态码.
 * @param deviceId      设备ID
 *
 *                      参数与指定路劲对应关系
 *                      IFlyHome.SKILLS             /skills
 *                      IFlyHome.ACCOUNTS           /accounts
 *                      IFlyHome.CLOCKS             /clocks
 *                      IFlyHome.CONTROLLED_DEVICES /controlled-devices
 *          1           表示调用成功
 *          0           表示未初始化 appId
 *          -1          表示找不到可调用的 WebView
 *          -2          传入参数不合法
 *          -3          未登录
 */
-(NSInteger) openWebPage:(NSString *) webViewTag pageIndex:(URL_PATH_ENUM) pageIndex deviceId:(NSString *) deviceId;

/**
 * 打开设备认证页
 * @param tag       tag
 * @param url           设备返回的认证 url
 *  @return  result      meaning
 *          1           表示调用成功
 *          0           表示未初始化 appId
 *          -1          表示找不到可调用的 WebView
 *          -2          传入参数不合法
 *          -3          未登录
 */
-(NSInteger) openAuthorizePage:(NSString *)tag url:(NSString *)url;

/**
 * 获取用户已绑定设备列表
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getUserDevices:(void (^)(NSInteger)) statusCode
        requestSuccess:(void (^)(id _Nonnull)) successData
           requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  删除用户绑定设备
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) deleteUserDevice:(NSString *)deviceId
              statusCode:(void (^)(NSInteger)) statusCode
          requestSuccess:(void (^)(id _Nonnull)) successData
             requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  获取音频管理首页数据
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getMusicGroups:(NSString *)deviceId
            statusCode:(void (^)(NSInteger)) statusCode
        requestSuccess:(void (^)(id _Nonnull)) successData
           requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取音频管理分组数据列表
 *  groupId : 分组id
 *  page : 页码
 *  limit : 每页数量
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getMusicGroupsList:(NSInteger)page
                 limit:(NSInteger)limit
               groupId:(NSString *)groupId
            statusCode:(void (^)(NSInteger)) statusCode
        requestSuccess:(void (^)(id _Nonnull)) successData
           requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  音乐搜索
 *  deviceId : 设备ID
 *  keyword : 关键字
 *  page : 页码
 *  limit : 每页数量
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) searchMusic:(NSString *)deviceId
            keyword:(NSString *)keyword
               page:(NSInteger) page
              limit:(NSInteger) limit
         statusCode:(void (^)(NSInteger)) statusCode
     requestSuccess:(void (^)(id _Nonnull)) successData
        requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  用户已收藏列表
 *  deviceId :  设备ID
 *  sourceType : 信源
 *  startId : 列表最后的音乐id
 *  limit : 每页数量
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getMusicCollections:(NSString *) deviceId
                 sourceType:(NSString *) sourceType
                    startId:(NSString *) startId
                      limit:(NSInteger)limit
                 statusCode:(void (^)(NSInteger)) statusCode
             requestSuccess:(void (^)(id _Nonnull)) successData
                requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  收藏音乐
 *  mediaId : 音乐ID
 *  sourceType : 信源
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) likeMusic:(NSString *)mediaId
       sourceType:(NSString *) sourceType
       statusCode:(void (^)(NSInteger)) statusCode
   requestSuccess:(void (^)(id _Nonnull)) successData
      requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  取消收藏音乐
 *  mediaId : 音乐ID
 *  sourceType : 信源
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) unlikeMusic:(NSArray *)mediaIds
         sourceType:(NSString *) sourceType
         statusCode:(void (^)(NSInteger)) statusCode
     requestSuccess:(void (^)(id _Nonnull)) successData
        requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  获取指定设备当前播放器状态
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getMusicControlState:(NSString *)deviceId
                  statusCode:(void (^)(NSInteger)) statusCode
              requestSuccess:(void (^)(id _Nonnull)) successData
                 requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  指定设备播放音乐
 *  deviceId : 设备ID
 *  mediaId : 音乐ID
 *  sourceType : 信源
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlPlay:(NSString *)deviceId
                 mediaId:(NSString *)mediaId
              sourceType:(NSString *) sourceType
              statusCode:(void (^)(NSInteger)) statusCode
          requestSuccess:(void (^)(id _Nonnull)) successData
             requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  指定设备播放用户收藏的音乐，mediaId 为空时默认第一首开始播放
 *  deviceId : 设备ID
 *  mediaId : 音乐ID
 *  sourceType : 信源
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlPlayCollections:(NSString *)deviceId
                            mediaId:(NSString *)mediaId
                         sourceType:(NSString *) sourceType
                         statusCode:(void (^)(NSInteger)) statusCode
                     requestSuccess:(void (^)(id _Nonnull)) successData
                        requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  指定设备播放分类/榜单下所有音乐，mediaId 为空时默认第一首开始播放
 *  deviceId : 设备ID
 *  groupId : 分类ID
 *  mediaId : 音乐ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlPlayGroup:(NSString *)deviceId
                            groupId:(NSString *)groupId
                            mediaId:(NSString *)mediaId
                         statusCode:(void (^)(NSInteger)) statusCode
                     requestSuccess:(void (^)(id _Nonnull)) successData
                        requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  指定设备停止播放
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlStop:(NSString *)deviceId
              statusCode:(void (^)(NSInteger)) statusCode
          requestSuccess:(void (^)(id _Nonnull)) successData
             requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  指定设备继续播放
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlResume:(NSString *)deviceId
                statusCode:(void (^)(NSInteger)) statusCode
            requestSuccess:(void (^)(id _Nonnull)) successData
               requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  指定设备播放上一首
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlPrevious:(NSString *)deviceId
                  statusCode:(void (^)(NSInteger)) statusCode
              requestSuccess:(void (^)(id _Nonnull)) successData
                 requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  指定设备播放下一首
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlNext:(NSString *)deviceId
              statusCode:(void (^)(NSInteger)) statusCode
          requestSuccess:(void (^)(id _Nonnull)) successData
             requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  指定设备控制音量，volume 范围 [0,100]
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) musicControlVolume:(NSString *)deviceId
                  volume:(NSInteger)volume
              statusCode:(void (^)(NSInteger)) statusCode
          requestSuccess:(void (^)(id _Nonnull)) successData
             requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  设置设备别名
 *  deviceId : 设备ID
 *  alias : 别名
 *  childrenMode : 儿童模式
 *  continousModel : 是否开启持续交互
 *  zone:设备位置
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) setDeviceAlias:(NSString *)deviceId
                 alias:(NSString *)alias
         continousMode:(BOOL) continousMode
          childrenMode:(BOOL) childrenMode
                  zone:(NSString *) zone
            statusCode:(void (^)(NSInteger)) statusCode
        requestSuccess:(void (^)(id _Nonnull)) successData
           requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取设备详情
 *  deviceId : 设备ID
 *  statusCode : 响应码
 *  successData : 请求成功返回的数据
 *  failData : 请求失败返回的数据
 */
-(void) getDeviceInfo:(NSString *)deviceId
           statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  设备重启
 *  deviceId : 设备ID
 */
-(void) rebootDevice:(NSString *)deviceId
          statusCode:(void (^)(NSInteger)) statusCode
      requestSuccess:(void (^)(id _Nonnull)) successData
         requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  设备恢复出厂设置
 *  deviceId : 设备ID
 */
-(void) restoreDeviceToFactorySetting:(NSString *)deviceId
                           statusCode:(void (^)(NSInteger)) statusCode
                       requestSuccess:(void (^)(id _Nonnull)) successData
                          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  设备重新配网
 *  deviceId : 设备ID
 */
-(void) resetDeviceNetwork:(NSString *)deviceId
                statusCode:(void (^)(NSInteger)) statusCode
            requestSuccess:(void (^)(id _Nonnull)) successData
               requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  红外按键测试
 *  clientDeviceId : 设备ID
 *  extends : 扩展参数
 */
-(void) infraredButtonTest:(NSString *)clientDeviceId
                   extends:(NSDictionary *) extends
                statusCode:(void (^)(NSInteger)) statusCode
            requestSuccess:(void (^)(id _Nonnull)) successData
               requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  红外添加设备信息
 *  clientDeviceId : 设备ID
 *  extends : 扩展参数
 */
-(void) infraredAddDeviceInfo:(NSString *)clientDeviceId
                      extends:(NSDictionary *) extends
                statusCode:(void (^)(NSInteger)) statusCode
            requestSuccess:(void (^)(id _Nonnull)) successData
               requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取用户详细
 */
-(void) getUserInfo:(void (^)(NSInteger)) statusCode
     requestSuccess:(void (^)(id _Nonnull)) successData
        requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  获取内容账号信息
 */
-(void) getAccount:(void (^)(NSInteger)) statusCode
    requestSuccess:(void (^)(id _Nonnull)) successData
       requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  获取用户UserId
 */
-(void) getUserId:(void (^)(NSInteger)) statusCode
   requestSuccess:(void (^)(id _Nonnull)) successData
      requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取信源列表
 */
-(void) getMediaSources:(void (^)(NSInteger)) statusCode
     requestSuccess:(void (^)(id _Nonnull)) successData
        requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  取消信源所有收藏
 *  sourceType : 信源类型
 */
-(void) deleteMediaSourcesWithType:(NSString *) sourceType
                        statusCode:(void (^)(NSInteger)) statusCode
                    requestSuccess:(void (^)(id _Nonnull)) successData
                       requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取内容分组列表
 *  deviceId : 设备ID
 *  sectionId : 分组id
 */
-(void) getMediaGroupList:(NSString *) sectionId
                 deviceId:(NSString *) deviceId
               statusCode:(void (^)(NSInteger)) statusCode
           requestSuccess:(void (^)(id _Nonnull)) successData
              requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  根据设备clientId获取设备信息
 *  clientId : clientId
 */
-(void) getClientInfo:(NSString *) clientId
           statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取设备信息
 */
-(void) getClientInfos:(void (^)(NSInteger)) statusCode
        requestSuccess:(void (^)(id _Nonnull)) successData
           requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  根据deviceId获取deviceCode
 *  clientId : clientId
 *  deviceId : 设备ID
 */
-(void) getDeviceCode:(NSString *) clientId
             deviceId:(NSString *) deviceId
           statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  根据deviceCode轮训获取状态
 *  deviceCode : deviceCode
 */
-(void) getBLEAuthrization:(NSString *) deviceCode
                statusCode:(void (^)(NSInteger)) statusCode
            requestSuccess:(void (^)(id _Nonnull)) successData
               requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  查看专辑
 *  deviceId : 设备id
 *  albumId : 专辑id
 *  source_type : 信源类型 (kugou)
 *  business : 业务类型（如：music）
 *  deviceId : 设备id
 *  deviceId : 设备id
 */
-(void) getAlbum:(NSString *_Nullable) albumId
        deviceId:(NSString *_Nullable) deviceId
      sourceType:(NSString *_Nullable) sourceType
        business:(NSString *_Nullable) business
           limit:(NSInteger) limit
            page:(NSInteger) page
      statusCode:(void (^)(NSInteger)) statusCode
  requestSuccess:(void (^)(id _Nonnull)) successData
     requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  收藏
 *  mediaId : 资源ID
 *  sourceType : 信源类型 (kugou)
 *  likeType : 收藏类型（single:单曲 ， album:专辑）
 *  business : 业务类型（如：music）
 *  tagId : 标签id
 *  albumId : 专辑id
 */
-(void) likeMedia:(NSString *_Nullable) mediaId
       sourceType:(NSString *_Nullable) sourceType
         likeType:(NSString *_Nullable) likeType
         business:(NSString *_Nullable) business
            tagId:(NSInteger) tagId
          albumId:(NSString *_Nullable) albumId
       statusCode:(void (^)(NSInteger)) statusCode
   requestSuccess:(void (^)(id _Nonnull)) successData
      requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  取消收藏（单曲/专辑）
 *  tagId : 标签id
 *  likeType : 收藏类型 (single/album)
 *  mediaIds : 信源id数组
 */
-(void) unLikeMediaWithLikeType:(NSString *) likeType
                          tagId:(NSInteger) tagId
                       mediaIds:(NSArray *_Nullable) mediaIds
                     statusCode:(void (^)(NSInteger)) statusCode
                 requestSuccess:(void (^)(id _Nonnull)) successData
                    requestFail:(void (^)(id _Nonnull)) failData;

/**
 * 获取收藏标签列表
 */
-(void) getCollectionTags:(void (^)(NSInteger)) statusCode
           requestSuccess:(void (^)(id _Nonnull)) successData
              requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  我的收藏列表
 *  deviceId : 设备ID
 *  tagId : 标签ID
 */
-(void) getCollectionList:(NSString *_Nullable) deviceId
                    tagId:(NSInteger) tagId
               statusCode:(void (^)(NSInteger)) statusCode
           requestSuccess:(void (^)(id _Nonnull)) successData
              requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  播放列表
 *  deviceId:设备列表
 */
-(void) getPlayList:(NSString *) deviceId
         statusCode:(void (^)(NSInteger)) statusCode
     requestSuccess:(void (^)(id _Nonnull)) successData
        requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  专辑播放
 *  deviceId:设备列表
 *  mediaId : 资源ID
 *  sourceType : 信源类型 (kugou)
 *  likeType : 收藏类型（single:单曲 ， album:专辑）
 *  business : 业务类型（如：music）
 *  albumId : 专辑id
 */
-(void) playAlbum:(NSString *) deviceId
          albumId:(NSString *) albumId
          mediaId:(NSString *) mediaId
       sourceType:(NSString *) sourceType
        bussiness:(NSString *) bussiness
       statusCode:(void (^)(NSInteger)) statusCode
   requestSuccess:(void (^)(id _Nonnull)) successData
      requestFail:(void (^)(id _Nonnull)) failData;

/**
 * 收藏歌单播放
 *  deviceId:设备列表
 *  mediaId : 资源ID
 *  tagId : 标签ID
 */
-(void) playCollections:(NSString *) deviceId
                  tagId:(NSInteger) tagId
                mediaId:(NSString *) mediaId
             statusCode:(void (^)(NSInteger)) statusCode
         requestSuccess:(void (^)(id _Nonnull)) successData
            requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  播放列表播放
 *  deviceId:设备列表
 *  mediaId : 资源ID
 */
-(void) playNow:(NSString *) deviceId
        mediaId:(NSString *) mediaId
     statusCode:(void (^)(NSInteger)) statusCode
 requestSuccess:(void (^)(id _Nonnull)) successData
    requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  同步酷狗音乐收藏
 */
-(void) asyncKugouCollections:(void (^)(NSInteger)) statusCode
              requestSuccess:(void (^)(id _Nonnull)) successData
                 requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  留声音库列表
 */
-(void) transformVoices:(void (^)(NSInteger)) statusCode
         requestSuccess:(void (^)(id _Nonnull)) successData
            requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  更换留声发言人
 *  deviceId:设备ID
 *  voiceId:变声列表ID
 */
-(void) transformVoices:(NSString *) deviceId
                voiceId:(NSString *) voiceId
             statusCode:(void (^)(NSInteger)) statusCode
         requestSuccess:(void (^)(id _Nonnull)) successData
            requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  取消留声发音人
 *  deviceId:设备ID
 */
-(void) transformVoicesClear:(NSString *) deviceId
                  statusCode:(void (^)(NSInteger)) statusCode
              requestSuccess:(void (^)(id _Nonnull)) successData
                 requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取内容账号登陆状态
 *  type:账号类型（kugou,liusheng）
 */
-(void) getAccountType:(NSString *) type
            statusCode:(void (^)(NSInteger)) statusCode
        requestSuccess:(void (^)(id _Nonnull)) successData
           requestFail:(void (^)(id _Nonnull)) failData;


/**
 *  获取内容账号类型
 */
-(void) getAccountsType:(void (^)(NSInteger)) statusCode
        requestSuccess:(void (^)(id _Nonnull)) successData
           requestFail:(void (^)(id _Nonnull)) failData;
/**
 *  注销账号
 */
-(void) revokeAccount:(id<IFLYOSsdkLoginDelegate>) handler;

/**
 *  根据clientId获取AuthCode(AP配网)
 *  clientId:设备client_id
 */
-(void) getAuthCode:(NSString *) clientId
         statusCode:(void (^)(NSInteger)) statusCode
     requestSuccess:(void (^)(id _Nonnull)) successData
        requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  检查AuthCode是否授权成功(AP配网)
 *  authCode: 授权code
 */
-(void) checkAuthCode:(NSString *) authCode
           statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  获取标签
 *  authCode: 授权code
 */
-(void) getRecordsTags:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  查看播放记录接口
 *  device_id: 设备ID
 *  tag_id:1 音乐/2 有声/3 视频， 默认是 1
 */
-(void) getRecordsPlay:(NSString *) device_id
                tag_id:(NSInteger) tag_id
            statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  删除播放记录
 *  device_id: 设备ID
 *  tag_id:标签数组，删除某个标签下的记录，即全选;若不传，则删除所有标签的记录
 *  ids:要删除的记录 id，如[1,2,3]，全选删除时不传该字段
 */
-(void) deleteRecords:(NSString *) device_id
               tag_id:(NSInteger) tag_id
                  ids:(NSArray *) ids
            statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;

/**
 *  播放记录列表
 *  device_id: 设备ID
 *  tag_id:标签Id
 *  source_type:信源
 *  media_id:音乐ID（不填就播放全部）
 */
-(void) playRecordsList:(NSString *) device_id
            source_type:(NSString *) source_type
               media_id:(NSString *) media_id
                 tag_id:(NSInteger) tag_id
            statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;


@end
