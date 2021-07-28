//
//  AboutViewController.m
//  smartwasp
//
//  Created by luotao on 2021/7/2.
//

#import "AboutViewController.h"
#import "NetDAO.h"
#import "Loading.h"
#import "UIViewHelper.h"
#import "iToast.h"
#import "SuggestViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"about_us", nil);
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionView.text = [NSString stringWithFormat:@"Version %@",infoDictionary[@"CFBundleShortVersionString"]];

    // Do any additional setup after loading the view from its nib.
}
//检查更新
- (IBAction)onCheckClick:(id)sender {
    [Loading show:nil];
    [[NetDAO sharedInstance] post:@{@"type":@"3"}
                             path:@"api/checkUpdate"  callBack:^(BaseBean * _Nonnull cData) {
        [Loading dismiss];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
        if(!cData.errCode && cData.data){
            NSString *new_build = [infoDictionary objectForKey:@"versionCode"];
            if(new_build.intValue > app_build.intValue){
                
            }else{
                [UIViewHelper showAlert:NSLocalizedString(@"newer_version", nil) target:self];
            }
        }else{
            [[iToast makeText:NSLocalizedString(@"error_version", nil)] show];
        }
    }];
}

//意见建议
- (IBAction)onSuggestClick:(id)sender {
    SuggestViewController *svc = [SuggestViewController new];
    [self.navigationController pushViewController:svc animated:YES];
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
