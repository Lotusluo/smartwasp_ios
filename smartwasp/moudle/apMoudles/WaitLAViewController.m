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

@interface WaitLAViewController ()

//等待连接到LA网络的任务
@property(nonatomic,strong)NSString *taskLAName;

@end

@implementation WaitLAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //循环检查当前wifi是否为LA开头
    self.taskLAName = [JCGCDTimer timerTask:^{
        NSString *cssid = ServiceUtil.wifiSsid;
        NSLog(@"search ssid:%@",cssid);
        NSRange range = [cssid rangeOfString:@"^LA_" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            if (self.isViewLoaded && self.view.window){
                //发现连接到设备，开始进入配网
                MatchLAViewController *mvc = MatchLAViewController.new;
                [self.navigationController pushViewController:mvc animated:YES];
            }
            [JCGCDTimer canelTimer:self.taskLAName];
        }
    } start:0 interval:5 repeats:YES async:NO];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated{
    [JCGCDTimer canelTimer:self.taskLAName];
}

-(void)dealloc{
    NSLog(@"WaitLAViewController dealloc");
}

- (IBAction)onBackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
