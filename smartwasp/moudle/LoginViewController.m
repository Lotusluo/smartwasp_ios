//
//  LoginViewController.m
//  iflyosSDKDemo
//
//  Created by admin on 2018/9/6.
//  Copyright © 2018年 test. All rights reserved.
//

#import "LoginViewController.h"
#import <WebKit/WebKit.h>
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import "Loading.h"
#import "UserBean.h"
#import <iflyosSDKForiOS/IFLYOSUIColor+IFLYOSColorUtil.h>
#import "CodingUtil.h"
#import "ConfigDAO.h"
#import "NSObject+YYModel.h"
#import "iToast.h"
#import "WebPageViewController.h"
#import "NetDAO.h"
#import "AppDelegate+Global.h"
#import "AppDelegate.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

#define LOGIN_PAGE @"loginPage"
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)

@interface LoginViewController ()
@property(strong,nonatomic) WKWebView *webView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKUserContentController *userContentController = [[WKUserContentController alloc]init];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    configuration.userContentController = userContentController;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, STATUS_HEIGHT ,SCREEN_WIDTH, SCREEN_HEIGHT) configuration:configuration];
    [self.view addSubview:self.webView];

    if (@available(iOS 11.0, *)) {
        if ([self.webView.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IFLYOSSDK shareInstance] registerWebView:self.webView handler:self tag:LOGIN_PAGE];
    [[IFLYOSSDK shareInstance] setWebViewDelegate:self tag:LOGIN_PAGE];
    [[IFLYOSSDK shareInstance] openLogin:LOGIN_PAGE];
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IFLYOSSDK shareInstance] unregisterWebView:LOGIN_PAGE];
}

/**
 *  新页面打开
 *  tag : 标识符
 *  noBack : 禁止手势返回（1:禁止 ， 0:不禁止）
 */
-(void) openNewPage:(id) tag noBack:(NSNumber *)noBack{
    NSLog(@"打开新网页：%@ noBack:%@",tag,noBack);
    WebPageViewController *newPage = [WebPageViewController createNewPageWithTag:tag];
    newPage.isInterupt = true;
    [self.navigationController pushViewController:newPage animated:YES];
}

/**
 *  登录成功
 */
-(void) onLoginSuccess{
    //登陆成功之后请求用户信息并保存本地并提交私有服务器
    [Loading show:nil];
    [[IFLYOSSDK shareInstance] getUserInfo:^(NSInteger code) {
    } requestSuccess:^(id _Nonnull success) {
        UserBean *user = [UserBean yy_modelWithJSON:success];
        if(user){
            //将用户数据进行保存
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
            NSString *value = [CodingUtil hexStringFromData:data];
            if([[ConfigDAO sharedInstance] setKey:@"usr" forValue:value]){
                [self registerUuid:user];
            }else{
                //登陆失败
                [[iToast makeText:@"请重试!"] show];
                [Loading dismiss];
            }
        }else{
            //登陆失败
            [[iToast makeText:@"登陆信息错误,请重试!"] show];
            [Loading dismiss];
        }
    } requestFail:^(id _Nonnull error) {
        //登陆失败
        [Loading dismiss];
        [[iToast makeText:@"登陆失败,请重试!"] show];
    }];
}

//向服务器提交用户信息
-(void)registerUuid:(UserBean*) user{
    [[NetDAO sharedInstance] post:@{@"uid":user.user_id,
                                    @"deviceType":@"IOS"}
                             path:@"api/register"  callBack:^(BaseBean * _Nonnull cData) {
        [Loading dismiss];
        if(!cData.errCode || cData.errCode == 407){
            APPDELEGATE.user = user;
            [APPDELEGATE toMain];
        }else{
            //登陆失败
            [[iToast makeText:@"登陆失败,请重试!"] show];
        }
    }];
}

/**
 *  登录失败
 */
-(void) onLoginFailed:(NSInteger) type error:(NSError *) error{
    NSLog(@"登录失败:%li,%@",type,error.localizedDescription);
}

/**
 *  注销成功
 */
-(void) onLogoutSuccess{
    NSLog(@"注销成功");
}

/**
 *  注销失败
 */
-(void) onLogoutFailed:(NSInteger) type error:(id) error{
    
}

/**
 *  关闭页面打开
 */
-(void) closePage{
    NSLog(@"关闭页面");
}

/**
 * 网页加载完成时，如果读取到页面内带有形如
 * <meta name="head-color">#FFFFFF</meta>
 * 的标签时，将回调颜色
 */
-(void) updateHeaderColor:(NSString *) color{
    self.webView.scrollView.backgroundColor = [UIColor colorWithHexString:color];
    self.view.backgroundColor = [UIColor colorWithHexString:color];
}

/**
 * 网页加载完成时，将回调标题
 */
-(void) updateTitle:(NSString *) title{
    
}

-(void) dealloc{
    NSLog(@"离开");
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
