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
#import "cJSON.h"

@interface MatchLAViewController (){
    BOOL isOpen;
    CFSocketRef socket;
}

@end

@implementation MatchLAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSThread detachNewThreadSelector:@selector(connectServer) toTarget:self withObject:nil];
    // Do any additional setup after loading the view from its nib.
}

//连接服务器
- (void)connectServer{
    NSLog(@"开始配网");
    socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, serverConnectCallBack, NULL);
    if (socket != nil) {
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = inet_addr("192.168.51.1");
        addr.sin_port = htons(8080);
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8*)&addr, sizeof((addr)));
        //连接服务器
        CFSocketError result = CFSocketConnectToAddress(socket, address, 5);
        //启用新线程来读取服务器响应的数据
        if (result == kCFSocketSuccess) {
            isOpen = YES;
            [NSThread detachNewThreadSelector:@selector(readStream) toTarget:self withObject:nil];
        }
        CFRunLoopRef cfrl = CFRunLoopGetCurrent();
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
        CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
        CFRelease(source);
        CFRunLoopRun();
        CFRelease(cfrl);
    }
    printf("socket dead!");
}

//连接成功的回调函数
void serverConnectCallBack(CFSocketRef socket,CFSocketCallBackType type,CFDataRef address,const void* data,void *info){
    if (data != NULL) {
        //error
        printf("connect error!");
        return;
    }
    //连接成功，发送时间戳
    time_t timestamp;
    time(&timestamp);
    cJSON *jsonObject;
    jsonObject = cJSON_CreateObject();
    char buf[30] = "";
    sprintf(buf, "%ld", timestamp);
    cJSON_AddStringToObject(jsonObject,"timestamp",buf);
    const char *out = cJSON_PrintUnformatted(jsonObject);
    send(CFSocketGetNative(socket), out, strlen(out) + 1, 1);
    printf("%s\n",out);
    cJSON_Delete(jsonObject);
}

//读取数据
- (void)readStream{
    char buff[2048];
    ssize_t redLen;
    ssize_t buffLen = sizeof(buff);
    while((redLen = recv(CFSocketGetNative(socket),buff,buffLen,0))){
        NSString *json = [[NSString alloc] initWithBytes:buff length:redLen encoding:NSUTF8StringEncoding];
        NSLog(@"json:%@",json);
    }
}

//发送数据
-(void)sendToServer:(NSString*)msg{
    if (isOpen) {
        const char *data = [msg UTF8String];
        send(CFSocketGetNative(socket), data, strlen(data) + 1, 1);
    }
}

//退出
- (IBAction)onBackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//销毁
-(void)dealloc{
    if(socket){
        CFRelease(socket);
    }
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
