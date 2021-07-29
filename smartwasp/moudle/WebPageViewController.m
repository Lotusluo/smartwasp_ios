//
//  NewPageViewController.m
//  iflyosSDKDemo
//
//  Created by admin on 2018/9/10.
//  Copyright © 2018年 test. All rights reserved.
//

#import "WebPageViewController.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import "CodingUtil.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import "UIViewHelper.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface WebPageViewController ()<WKNavigationDelegate,IFLYOSsdkAuthDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (copy,nonatomic) NSString *Tag;
@property (nonatomic,assign) NSInteger count;
@end

@implementation WebPageViewController

-(int)randomInt{
    int value = (arc4random() % 10000) + 1;
    return value;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.progressView.hidden = YES;
    self.Tag = [NSString stringWithFormat:@"newPage-%i",[self randomInt]];
    NSLog(@"创建webView :%@",NSStringFromClass([self class]));
    WKUserContentController *userContentController = [[WKUserContentController alloc]init];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    configuration.userContentController = userContentController;
    self.webView.configuration.userContentController = userContentController;
    [[IFLYOSSDK shareInstance] setWebViewDelegate:self tag:self.Tag];
    [self.webView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    if (self.contextTag) {
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag contextTag:self.contextTag];
        [[IFLYOSSDK shareInstance] openNewPage:self.Tag];
    }
    if(self.openUrl){
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.openUrl]]];
        self.progressView.hidden = NO;
        // 给webview添加监听
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
    
    if(self.path){
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag];
        [[IFLYOSSDK shareInstance] openWebPage:self.Tag pageIndex:self.path deviceId:APPDELEGATE.curDevice.device_id];
    }
    
    if(self.authUrl){
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag];
        [[IFLYOSSDK shareInstance] openAuthorizePage:self.Tag url:self.authUrl];
    }
    
    if(self.isInterupt){
        self.webView.navigationDelegate = self;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.count = self.navigationController.viewControllers.count;
    NSLog(@"viewWillAppear:%ld",self.count);
    [[IFLYOSSDK shareInstance] webViewAppear:self.Tag];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSInteger nowCount = self.navigationController.viewControllers.count;
    NSLog(@"viewWillDisappear:%ld",nowCount);
    if(self.count - 1 == nowCount){
        //此时为该VC销毁的时候
        [[IFLYOSSDK shareInstance] unregisterWebView:self.Tag];
        return;
    }
    [[IFLYOSSDK shareInstance] webViewDisappear:self.Tag];
}

// 监听事件处理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress  >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:YES];
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

-(void)closePage{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)openNewPage:(id) tag noBack:(NSNumber *)noBack{
    WebPageViewController *newPage = [WebPageViewController createNewPageWithTag:tag];
    [self.navigationController pushViewController:newPage animated:YES];
}

/**
 * 网页加载完成时，将回调标题
 */
-(void)updateTitle:(NSString *) title{
    title = (title == NULL || title.length < 1 ) ? NSLocalizedString(@"skill_desc", nil) : title;
    self.navigationItem.leftBarButtonItem.title = @"";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.title = title;
}

-(void)dealloc{
    [self.webView setNavigationDelegate:nil];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    @try {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    } @catch (NSException *exception) {
    } @finally {
    }
    NSLog(@"================newPage释放================");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(!self.isInterupt) return;
    NSString *urlStr = navigationAction.request.URL.absoluteString;
    if(
       [urlStr containsString:@"iflyhome_app_agreement.html"] ||
       [urlStr containsString:@"iflyhome_app_privacypolicy.html"]){
        //替换用户协议与隐私政策
        NSString *endStr =  urlStr.pathComponents.lastObject;
//        NSRange range = [endStr rangeOfString:@"iflyhome"];
        endStr = [endStr stringByReplacingOccurrencesOfString:@"iflyhome" withString:@"smartwasp"];
        NSString *bundleStr = [[NSBundle mainBundle] pathForResource:endStr ofType:nil];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:bundleStr]];
        [self.webView loadRequest:request];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}
    
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        NSString *tittle = [NSString stringWithFormat:@"%@",object];
        if(![tittle isEqualToString:@""]){
            [self updateTitle:tittle];
        }
    }];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if (error.code==-999) {
        return;
    }
}

#pragma mark -- IFLYOSsdkAuthDelegate
-(void)onAuthSuccess{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"devBindNotification" object:self.authUrl userInfo:nil];
}

-(void)onAuthFailed{
    [UIViewHelper showAlert:NSLocalizedString(@"auth_err", nil) target:self];
}

-(void)onAuthReject{
    [UIViewHelper showAlert:NSLocalizedString(@"auth_err", nil) target:self];
}

+(WebPageViewController *)createNewPageWithTag:(NSString *)tag{
    WebPageViewController *vc = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
    vc.contextTag = tag;
    vc.disappearHideBar = YES;
    return vc;
}

+(WebPageViewController *)createNewPageWithUrl:(NSString *)url{
    WebPageViewController *vc = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
    vc.openUrl = url;
    vc.disappearHideBar = YES;
    return vc;
}

+(WebPageViewController *)createNewPageWithPath:(URL_PATH_ENUM) path{
    WebPageViewController *vc = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
    vc.path = path;
    vc.disappearHideBar = YES;
    return vc;
}

+(WebPageViewController *)createNewPageWithAuth:(NSString *)url{
    WebPageViewController *vc = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
    vc.authUrl = url;
    vc.disappearHideBar = YES;
    return vc;
}

@end
