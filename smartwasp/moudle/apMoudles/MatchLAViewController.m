//
//  MatchLAViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import "MatchLAViewController.h"
#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import <arpa/inet.h>
#import "NSObject+YYModel.h"
#import "IFLYOSSDK.h"
#import "cJSON.h"
#import "ApHsBean.h"
#import "PrevBindViewController.h"
#import "JCGCDTimer.h"
#import "UIViewHelper.h"
#import "IFlyOSBean.h"
#import "UIViewController+BackButtonHandler.h"
#import "AppDelegate.h"
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

static MatchLAViewController *matchMV;

@interface MatchLAViewController ()<BackButtonHandlerProtocol>{
    BOOL isOpen;
    CFSocketRef socket;
    char *buffer;//总缓存
    size_t bufferLen;//总缓存长度
    size_t bufferPos;//总缓存的索引
    int askTimez;//轮询次数
    CFRunLoopRef runloop;
}
//联网进度条
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
//联网提示语
@property (weak, nonatomic) IBOutlet UILabel *tipView;
//当前操作的步骤
@property(nonatomic,assign)NSInteger step;
//等待联网成功的轮询的任务
@property(nonatomic,strong)NSString *taskAskName;
//联网成功的倒计时任务
@property(nonatomic,strong)NSString *taskCountName;
//配网设备信息
@property(nonatomic,strong)ApHsBean *aphsBean;

@end

@implementation MatchLAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem.title = @"";
    //先定义总缓存指向
    bufferLen = BUFSIZ;
    buffer = (char *)malloc(bufferLen);
    matchMV = self;
    self.navigationItem.leftBarButtonItem.title = @"";
    [NSThread detachNewThreadSelector:@selector(connectServer) toTarget:self withObject:nil];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // Do any additional setup after loading the view from its nib.
}

//连接服务器
- (void)connectServer{
    [NSThread sleepForTimeInterval:2];
    NSLog(@"connectServer");
    socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, serverConnectCallBack, NULL);
    if (socket != nil) {
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = inet_addr([self.hostName UTF8String]);
        addr.sin_port = htons(8080);
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8*)&addr, sizeof((addr)));
        //连接服务器
        CFSocketError result = CFSocketConnectToAddress(socket, address, 5);
        //启用新线程来读取服务器响应的数据
        if (result == kCFSocketSuccess) {
            isOpen = YES;
            [NSThread detachNewThreadSelector:@selector(readStream) toTarget:self withObject:nil];
        }
        runloop = CFRunLoopGetCurrent();
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
        CFRunLoopAddSource(runloop, source, kCFRunLoopCommonModes);
        CFRelease(source);
        CFRunLoopRun();
    }
}

//连接成功的回调函数
void serverConnectCallBack(CFSocketRef socket,CFSocketCallBackType type,CFDataRef address,const void* data,void *info){
    if (data != NULL) {
        [matchMV onServerError:data];
        return;
    }
    //开始握手
    NSLog(@"连接成功，开始握手");
    time_t timestamp;
    time(&timestamp);
    cJSON *jsonObject;
    jsonObject = cJSON_CreateObject();
    char buf[30] = "";
    sprintf(buf, "%ld", timestamp);
    cJSON_AddStringToObject(jsonObject,"timestamp",buf);
    const char *out = cJSON_PrintUnformatted(jsonObject);
    send(CFSocketGetNative(socket), out, strlen(out) + 1, 1);
    cJSON_Delete(jsonObject);
    matchMV.step = 1;

}

//设置操作步骤
-(void)setStep:(NSInteger)step{
    @synchronized (matchMV) {
        NSLog(@"setStep:%ld,thread type:%@",step,NSThread.currentThread);
        _step = step;
        if(_step == 1){
            //连接成功发送握手数据
            [self setProgress:0.2];
        }else if(_step == 2){
            //收到握手数据发送配网数据
            [self askAuth];
        }else if(_step == 3){
            //配网成功开始倒计时关闭
            [JCGCDTimer canelTimer:self.taskAskName];
            [JCGCDTimer canelTimer:self.taskCountName];
            NSLog(@"canelTimer taskCountName");
            //TODO 测试__block对当前对象的引用关系
            __block int count = 5;
            self.taskCountName = [JCGCDTimer timerTask:^{
                [self setProgress:1];
                NSLog(@"taskCount");
                self.tipView.text = [NSString stringWithFormat:@"AP配网授权成功，请等待%d秒",count];
                if(count--<=1){
                    [JCGCDTimer canelTimer:self.taskCountName];
                    NSLog(@"canelTimer taskCountName");
                    self.step = 4;
                    return;
                }
            } start:0 interval:1 repeats:YES async:NO];
        }else if(_step == 4){
            matchMV = nil;
            //派发配网成功通知
            NSString *authUrl = [NSString stringWithFormat:@"clientId=%@&sn=%@",self.aphsBean.client_id,self.aphsBean.did];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"devBindNotification" object:authUrl userInfo:nil];
        }
    }
}

//询问是否配网成功
-(void)askAuth{
    [self releaseSocket];
    askTimez = 1;
    //轮询是否配网成功
    [JCGCDTimer canelTimer:self.taskAskName];
    [JCGCDTimer canelTimer:self.taskCountName];
    NSLog(@"canelTimer taskCountName");
    self.taskAskName = [JCGCDTimer timerTask:^{
        [[IFLYOSSDK shareInstance] checkAuthCode:AUTHCODE.auth_code statusCode:^(NSInteger code) {
            self->askTimez++;
            if(self->askTimez>=2){
                [self setProgress:0.8];
            }
            if(self->askTimez>= 60){
                [JCGCDTimer canelTimer:self.taskAskName];
                [UIViewHelper showAlert:NSLocalizedString(@"err_net1", nil) target:self callBack:^{
                    //强制退出
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"devBindNotification" object:@"error" userInfo:nil];
                }];
            }
        } requestSuccess:^(id _Nonnull data) {
            self.step = 3;
        } requestFail:^(id _Nonnull data) {
            if([NSStringFromClass([data class]) containsString:@"_NSInlineData"]){
                NSString * errMsg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                IFlyOSBean *osBean = [IFlyOSBean yy_modelWithJSON:errMsg];
                if(osBean.code == 3001){
                    //未添加白名单
                    [JCGCDTimer canelTimer:self.taskAskName];
                    [UIViewHelper showAlert:NSLocalizedString(@"err_net2", nil) target:self callBack:^{
                        //强制退出
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"devBindNotification" object:@"error" userInfo:nil];
                    }];
                }
            }
            //_NSInlineData
        }];
    } start:0 interval:2 repeats:YES async:NO];
}

//读取数据
- (void)readStream{
    char buff[BUFSIZ];
    ssize_t readLen;
    while((readLen = recv(CFSocketGetNative(socket),buff,BUFSIZ,0))){
        if(readLen > 0){
            NSLog(@"读取到数据:%zd",readLen);
            ssize_t total = bufferPos + readLen;
            if(total > bufferLen){
                char *temp = buffer;
                //申请更多的地址空间
                buffer = (char*)malloc(total);
                memcpy(buffer, temp, bufferLen);
                free(temp);
                bufferLen = total;
            }
            //从buff的索引0-redLen依次读取字节到总缓存
            for(ssize_t i=0;i<readLen;i++){
                buffer[bufferPos++] = buff[i];
            }
            NSString *json = [[NSString alloc] initWithBytes:buffer length:bufferPos encoding:NSUTF8StringEncoding];
            if(self.step == 1){
                ApHsBean *aphsBeanTemp = [ApHsBean yy_modelWithJSON:json];
                if(aphsBeanTemp){
                    self.aphsBean = aphsBeanTemp;
                    bufferPos = 0;
                    //开始配网
                    cJSON *jsonObject;
                    jsonObject = cJSON_CreateObject();
                    cJSON_AddStringToObject(jsonObject,"ssid",[SSID UTF8String]);
                    cJSON_AddStringToObject(jsonObject,"bssid","");
                    cJSON_AddStringToObject(jsonObject,"password",[PWD UTF8String]);
                    cJSON_AddStringToObject(jsonObject,"auth_code",[AUTHCODE.auth_code UTF8String]);
                    const char *out = cJSON_PrintUnformatted(jsonObject);
                    send(CFSocketGetNative(socket), out, strlen(out) + 1, 1);
                    printf("readStream:%s\n",out);
                    cJSON_Delete(jsonObject);
                    self.step = 2;
                }
            }
        }else{
            [matchMV onServerError:"read-1"];
            break;
        }
    }
}

//服务连接错误
-(void)onServerError:(const void*)error{
    NSLog(@"onServerError:askTimez:%d",askTimez);
    [self releaseSocket];
    if(askTimez > 0)
        return;
    [UIViewHelper showAlert:NSLocalizedString(@"err_net3", nil) target:self callBack:^{
        //强制退出
        [[NSNotificationCenter defaultCenter] postNotificationName:@"devBindNotification" object:@"error" userInfo:nil];
    }];
}

//设置进度条动画
-(void)setProgress:(CGFloat)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressBar setProgress:progress animated:YES];
    });
}

- (BOOL)navigationShouldPopOnBackButton{
    [UIViewHelper showAlert:NSLocalizedString(@"err_net4", nil) target:self callBack:^{
        //强制退出
        [[NSNotificationCenter defaultCenter] postNotificationName:@"devBindNotification" object:@"error" userInfo:nil];
    } negative:YES];
    return NO;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [JCGCDTimer canelTimer:self.taskAskName];
    [JCGCDTimer canelTimer:self.taskCountName];
    NSLog(@"canelTimer taskCountName");
}

//释放连接服务
-(void)releaseSocket{
    if(socket){
        CFRelease(socket);
        socket = nil;
    }
    if(runloop){
        CFRunLoopStop(runloop);
        runloop = nil;
    }
    if(buffer){
        free(buffer);
        buffer = nil;
    }
}

//销毁
-(void)dealloc{
    [self releaseSocket];
    AUTHCODE = nil;
    NSLog(@"MatchLAViewController dealloc");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
