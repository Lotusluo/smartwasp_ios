//
//  WaitLAViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import "WaitLAViewController.h"
#import "MatchLAViewController.h"
#import "JCGCDTimer.h"
#import "ServiceUtil.h"
#import "iToast.h"
#import "LDSRouterInfo.h"
#import "UIViewHelper.h"
#import "SimplePing.h"
#import "Loading.h"


@interface WaitLAViewController ()<SimplePingDelegate>

//等待连接到LA网络的任务
@property(nonatomic,strong)NSString *taskLAName;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic,strong) SimplePing *ping;

@end

@implementation WaitLAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem.title = @"";
    self.nextBtn.hidden = YES;
    //循环检查当前wifi是否为LA开头
    self.taskLAName = [JCGCDTimer timerTask:^{
        NSString *cssid = ServiceUtil.wifiSsid;
        if(cssid){
            NSRange range = [cssid rangeOfString:@"^LA_" options:NSRegularExpressionSearch];
            self.nextBtn.hidden = range.location == NSNotFound;
        }
    } start:1 interval:5 repeats:YES async:NO];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [JCGCDTimer canelTimer:self.taskLAName];
}

-(void)dealloc{
    NSLog(@"WaitLAViewController dealloc");
}

- (IBAction)onNextClick:(id)sender {
    if(self.ping){
        [self.ping stop];
    }
    [Loading show:nil];
    NSDictionary *dict = [LDSRouterInfo getRouterInfo];
    NSString *router = dict[@"router"];
    if(router){
        self.ping = [[SimplePing alloc] initWithHostName:router];
        self.ping.delegate = self;
        [self.ping start];
    }else{
        [Loading dismiss];
        [UIViewHelper showAlert:@"请确保已连接至LA_网络" target:self];
    }
//    dns = "192.168.2.255";
//    ip = "192.168.2.85";
//    router = "192.168.2.1";
//    subnetMask = "255.255.255.0";
  
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address{
    NSLog(@"simplePing ok");
    [Loading dismiss];
    //发现连接到设备，开始进入配网
    MatchLAViewController *mvc = MatchLAViewController.new;
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error{
    NSLog(@"simplePing error");
    [Loading dismiss];
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
