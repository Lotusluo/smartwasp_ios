//
//  WaitLAViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import "WaitLAViewController.h"
#import "MatchLAViewController.h"
#import "ServiceUtil.h"
#import "iToast.h"
#import "LDSRouterInfo.h"
#import "UIViewHelper.h"
#import "SimplePing.h"
#import "Loading.h"
#import <CoreLocation/CoreLocation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import <arpa/inet.h>
#import "iToast.h"


@interface WaitLAViewController ()<CLLocationManagerDelegate,SimplePingDelegate>{
    dispatch_source_t _timer;
    CFSocketRef socket;
}

//等待连接到LA网络的任务
@property(nonatomic,strong)NSString *taskLAName;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic,strong) SimplePing *pinger;
@property (strong,nonatomic) CLLocationManager * mCLLocationManager;
@property (strong,nonatomic)UIAlertController* alert;
@end

@implementation WaitLAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem.title = @"";
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stop];
}

-(void)dealloc{
    NSLog(@"WaitLAViewController dealloc");
}

/**
  点击下一步进行配网
 */
- (IBAction)onNextClick:(id)sender {
    //地址位置权限
    if (@available(iOS 13.0, *)) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            self.mCLLocationManager = [[CLLocationManager alloc] init];
            self.mCLLocationManager.delegate = self;
            [self.mCLLocationManager requestWhenInUseAuthorization];
            return;
        }
    }
    [self onNext];
}

/**
 位置信息进行授权
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        [self onNext];
    }
}

/**
 下一步开始进行配网
 IOS14以上需要先判断是否有本地网络权限
 */
-(void)onNext{
//    MatchLAViewController *mvc = [MatchLAViewController new];
//    mvc.iconPath = self.iconPath;
//    mvc.hostName = @"192.168.51.1";
//    [self.navigationController pushViewController:mvc animated:YES];
    NSString *cssid = ServiceUtil.wifiSsid;
    if(cssid && [cssid rangeOfString:@"^LA_" options:NSRegularExpressionSearch].location != NSNotFound){
        NSDictionary *dict = [LDSRouterInfo getRouterInfo];
        NSString *router = dict[@"router"];
        if(router && ![router isEqualToString:@""]){
            [self checkLocalNetStatus:router];
            return;
        }
    }
    [UIViewHelper showAlert:NSLocalizedString(@"net_set3", nil) target:self];
}

- (void)stop{
    if (_pinger) {
        [_pinger stop];
    }
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    if(self.alert){
        [self.alert dismissViewControllerAnimated:YES completion:nil];
        self.alert = nil;
    }
}

- (void)checkLocalNetStatus:(NSString*)router{
    if (_timer) {
        [[iToast makeText:NSLocalizedString(@"wait_net", nil)] show];
        return;
    }
    NSLog(@"router:%@",router);
    _pinger = [[SimplePing alloc] initWithHostName:router];
    _pinger.delegate = self;
    [_pinger start];
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address{
    if (_timer) {
        return;
    }
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [pinger sendPingWithData:nil];
    });
    dispatch_resume(_timer);
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
    sequenceNumber:(uint16_t)sequenceNumber{
    [self stop];
    MatchLAViewController *mvc = [MatchLAViewController new];
    mvc.iconPath = self.iconPath;
    mvc.hostName = pinger.hostName;
    NSLog(@"**可以使用局域网:%@**",pinger.hostName);
    [self.navigationController pushViewController:mvc animated:YES];
}

-  (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error{
    [self stop];
    if (error.code == 65) {
        NSLog(@"**不可以使用局域网**");
        self.alert = [UIViewHelper showAlert:NSLocalizedString(@"no_internet1", nil) target:self callBack:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } positiveTxt:NSLocalizedString(@"confirm_btn", nil) negativeTxt:NSLocalizedString(@"cancel_btn1", nil)];
    }else{
        [[iToast makeText:NSLocalizedString(@"retry", nil)] show];
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
