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


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface WebPageViewController ()<WKNavigationDelegate,IFLYOSsdkAuthDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property(copy,nonatomic) NSString *Tag;
@end

@implementation WebPageViewController

-(int) randomInt{
    int value = (arc4random() % 10000) + 1;
    return value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.Tag = [NSString stringWithFormat:@"newPage-%i",[self randomInt]];
    NSLog(@"创建webView :%@",NSStringFromClass([self class]));
    WKUserContentController *userContentController = [[WKUserContentController alloc]init];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    configuration.userContentController = userContentController;
    self.webView.configuration.userContentController = userContentController;
    [[IFLYOSSDK shareInstance] setWebViewDelegate:self tag:self.Tag];
    
    if (self.contextTag) {
        NSLog(@"WebPageViewController:contextTag");
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag contextTag:self.contextTag];
        [[IFLYOSSDK shareInstance] openNewPage:self.Tag];
    }
    
    
    if(self.openUrl){
        NSLog(@"WebPageViewController:openUrl");
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag contextTag:self.Tag];
        NSURL *url = [NSURL URLWithString:self.openUrl];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:req];
    }


    if(self.path){
        NSLog(@"WebPageViewController:path");
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag];
        [[IFLYOSSDK shareInstance] openWebPage:self.Tag pageIndex:self.path deviceId:APPDELEGATE.curDevice.device_id];
    }
    
    if(self.authUrl){
        NSLog(@"WebPageViewController:authUrl");
        [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:self.Tag];
        [[IFLYOSSDK shareInstance] openAuthorizePage:self.Tag url:self.authUrl];
    }
 
    if(self.isInterupt){
        self.webView.navigationDelegate = self;
        if (@available(iOS 7.0, *)) {
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                self.navigationController.interactivePopGestureRecognizer.delegate = self;
            }
        }
    }
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

-(void) viewWillAppear:(BOOL)animated{
    [[IFLYOSSDK shareInstance] webViewAppear:self.Tag];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IFLYOSSDK shareInstance] webViewDisappear:self.Tag];
}

-(void) closePage{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) openNewPage:(id) tag noBack:(NSNumber *)noBack{
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

-(void) dealloc{
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    NSLog(@"newPage释放");
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
