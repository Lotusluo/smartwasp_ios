//
//  CommonTabController.m
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import "CommonTabController.h"
#import "Toolbar.h"
#import <iflyosSDKForiOS/IFLYOSUIColor+IFLYOSColorUtil.h>
#import <WebKit/WebKit.h>
#import <Masonry.h>
#import "WebPageViewController.h"
#import "Loading.h"
#import "AppDelegate.h"
#import "UIViewHelper.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)

@interface CommonTabController ()
//工具栏
@property(nonatomic) Toolbar *toolbar;
//webview
@property(strong,nonatomic) WKWebView *webView;

@end

@implementation CommonTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initToolbar];
    WKUserContentController *userContentController = [[WKUserContentController alloc]init];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    configuration.userContentController = userContentController;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.view addSubview:self.webView];
    [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:_tag];
    [[IFLYOSSDK shareInstance] setWebViewDelegate:self tag:_tag];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)onRefreshClick:(id)sender {
    [Loading show:nil];
    NEED_MAIN_REFRESH_DEVICES = YES;
    [APPDELEGATE requestBindDevices];
}

//初始化自定义导航条
-(void)initToolbar{
    self.toolbar = [Toolbar newView];
    [self.view addSubview:self.toolbar];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //布局前重置一下toolbar的frame
    _toolbar.frame = CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, 49);
    //适配webview高度
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.top.equalTo(_toolbar.mas_bottom);
        CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
    }];
}

//设备选择通知
-(void)devSetCallback:(DeviceBean* __nullable) device{
    self.NEED_REFRESH_UI = YES;
    [self reloadData:device];
}

//处理设备媒体状态通知
-(void)mediaSetCallback:(MusicStateBean* __nullable) musicStateBean{
    if (self.isViewLoaded && self.view.window){
        if(musicStateBean && musicStateBean.isPlaying){
            [self.toolbar startJump];
            return;
        }
    }
    [self.toolbar stopJump];
}

//设备在线状态变更
-(void)onLineChangedCallback{
    [self.toolbar update];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.toolbar update];
    if(self.NEED_REFRESH_UI){
        [self reloadData:APPDELEGATE.curDevice];
    }
}

//重加载数据
-(void)reloadData:(DeviceBean *) device{
    self.toolbar.device = device;
    if (!self.isViewLoaded || !self.view.window){
        return;
    }
    UIView *emptyView = [self.view viewWithTag:1001];
    if(device){
        self.NEED_REFRESH_UI = NO;
        emptyView.hidden = YES;
        [[IFLYOSSDK shareInstance] openWebPage:_tag pageIndex:self.vcType deviceId:device.device_id];
    }else{
        [self.view bringSubviewToFront:emptyView];
        emptyView.hidden = NO;
        NSLog(@"为空");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IFLYOSSDK shareInstance] webViewAppear:_tag];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IFLYOSSDK shareInstance] webViewDisappear:_tag];
}

-(void)dealloc{
    NSLog(@"CommonTabController dealloc");
}

-(void)tempDo{
    [self.toolbar tempDo];
}

//打开一个新页面
-(void)openNewPage:(id) tag noBack:(NSNumber *)noBack{
    WebPageViewController *newPage = [WebPageViewController createNewPageWithTag:tag];
    [self.navigationController pushViewController:newPage animated:YES];
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
