//
//  AddDeviceViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/23.
//

#import "AddDeviceViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NormalToolbar.h"
#import "UIViewHelper.h"
#import "CodingUtil.h"
#import "PrevBindViewController.h"
#import "WebPageViewController.h"
#import "MainViewController.h"
#import "BaseBean.h"
#import "NetDAO.h"
#import "AppDelegate.h"
#import "WifiInfoViewController.h"
#import "ServiceUtil.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface AddDeviceViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet NormalToolbar *toolBar;
//有屏扫码授权
@property (weak, nonatomic) IBOutlet UIView *scanEntryBtn;
//党建配网
@property (weak, nonatomic) IBOutlet UIView *djEntryBtn;
@property (strong,nonatomic) CLLocationManager * mCLLocationManager;

@end

@implementation AddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolBar.title = @"添加主控设备";
    self.toolBar.titleColor = [UIColor blackColor];
    [UIViewHelper attachClick:self.scanEntryBtn target:self action:@selector(onScanClick)];
    [UIViewHelper attachClick:self.djEntryBtn target:self action:@selector(onDJClick)];
    //添加二维码扫码监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(qrCodeObserver:)
                                                 name:@"qrCodeNotification"
                                               object:nil];
    //添加音箱绑定成功监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devBindObserver:)
                                                 name:@"devBindNotification"
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
}

//扫码授权
-(void)onScanClick{
    //检查摄像权限
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        PrevBindViewController *pvc = PrevBindViewController.new;
        [self.navigationController pushViewController:pvc animated:YES];
        return;
    }
    __weak typeof(self) SELF = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted){
                [SELF onScanClick];
            }else{
                [UIViewHelper showAlert:@"您禁止了相机权限,请去设置页面打开。" target:SELF];
            }
        });
    }];
}

//党建
-(void)onDJClick{
    //地址位置权限
    if (@available(iOS 13.0, *)) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            self.mCLLocationManager = [[CLLocationManager alloc] init];
            self.mCLLocationManager.delegate = self;
            [self.mCLLocationManager requestWhenInUseAuthorization];
            return;
        }
    }
    [self goWifiConfig];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        [self goWifiConfig];
    }
}

-(void)goWifiConfig{
    NSLog(@"wifiName:%@",ServiceUtil.wifiSsid);
    WifiInfoViewController *wvc = WifiInfoViewController.new;
    wvc.ssid = ServiceUtil.wifiSsid;
    [self.navigationController pushViewController:wvc animated:YES];
}

#pragma mark --二维码扫码通知
/**
 XHFhttps://auth.iflyos.cn/oauth/device?user_code=223568&sn=XHFH0010010769&mac=202005010769&ctei=&proId=61&t=1624498955282&clientId=85274302-444e-4f73-8b9d-140c1a6c13a8
 */
-(void)qrCodeObserver:(NSNotification*)notification {
    NSString *qrCodeStr = notification.object;
    NSLog(@"qrCodeStr:%@",qrCodeStr);
    if(![qrCodeStr isEqualToString:@""] && [qrCodeStr containsString:@"oauth/device?user_code"]){
        //判断是否以XHF开头
        NSMutableString *newQrCodeStr = [NSMutableString stringWithString:qrCodeStr];
        NSRange range = [qrCodeStr rangeOfString:@"^XHF" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            [newQrCodeStr replaceCharactersInRange:range withString:@""];
            WebPageViewController *wvc = [WebPageViewController createNewPageWithAuth:newQrCodeStr];
            [self.navigationController pushViewController:wvc animated:YES];
            return;
        }
    }
    [UIViewHelper showAlert:@"二维码错误，请重试！" target:self];
}

#pragma mark --音箱绑定成功通知
-(void)devBindObserver:(NSNotification*)notification {
    NSString *query = notification.object;
    if([query isEqualToString:@"error"]){
        NEED_MAIN_REFRESH_DEVICES = NO;
        [self goParent];
        return;
    }
    __weak typeof(self) SELF = self;
    //解析相应的参数
    NSDictionary *params = [CodingUtil dictionaryFromQuery:query];
    [[NetDAO sharedInstance] post:@{@"clientIds":params[@"clientId"],
                                    @"deviceIds":params[@"sn"],
                                    @"uid":APPDELEGATE.user.user_id}
                             path:@"api/bind"  callBack:^(BaseBean * _Nonnull cData) {
//        if(!cData.errCode ){
            NEED_MAIN_REFRESH_DEVICES = YES;
//        }
        [SELF goParent];
    }];
}

//跳转上一页
-(void)goParent{
    for(id cvc in self.navigationController.childViewControllers){
        if([cvc isKindOfClass:MainViewController.class]){
            [self.navigationController popToViewController:cvc animated:YES];
            break;;
        }
    }
}



-(void)dealloc{
    NSLog(@"AddDeviceViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
