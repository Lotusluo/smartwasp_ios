//
//  CommonTabController.m
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import "CommonTabController.h"
#import "Toolbar.h"
#import <iflyosSDKForiOS/IFLYOSUIColor+IFLYOSColorUtil.h>
#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import <Masonry.h>
#import "NewPageViewController.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

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
    //对选择的设备进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devSetObserver:)
                                                 name:@"devSetNotification"
                                               object:nil];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc]init];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    configuration.userContentController = userContentController;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.view addSubview:self.webView];
    [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:_tag];
    [[IFLYOSSDK shareInstance] setWebViewDelegate:self tag:_tag];
    // Do any additional setup after loading the view from its nib.
    [self devSetObserver:nil];
}

//初始化自定义导航条
-(void) initToolbar{
    _toolbar = [Toolbar newView];
    [self.view addSubview:_toolbar];
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

#pragma mark - 处理通知
-(void)devSetObserver:(NSNotification*)notification {
    NSLog(@"收到设备选择的消息通知");
    if(APPDELEGATE.curDevice){
        [self.toolbar setDevName:APPDELEGATE.curDevice.alias];
        [self.toolbar setDevStatus:APPDELEGATE.curDevice.isOnLine];
        NSInteger code = [[IFLYOSSDK shareInstance] openWebPage:_tag pageIndex:self.vcType deviceId:APPDELEGATE.curDevice.device_id];
        if (code == -3) {
            NSLog(@"未登录，请先登录");
        }
    }else{
        [self.toolbar setEmpty];
    }
}

//打开一个新页面
-(void) openNewPage:(id) tag noBack:(NSNumber *)noBack{
    NewPageViewController *newPage = [NewPageViewController createNewPageWithTag:tag];
    [self.navigationController pushViewController:newPage animated:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IFLYOSSDK shareInstance] webViewAppear:_tag];
    [self.toolbar startJump];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IFLYOSSDK shareInstance] webViewDisappear:_tag];
    [self.toolbar stopJump];
}

-(void) dealloc{
    [[IFLYOSSDK shareInstance] unregisterWebView:_tag];
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
