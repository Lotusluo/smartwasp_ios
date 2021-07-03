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

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于我们";
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionView.text = [NSString stringWithFormat:@"Version %@",infoDictionary[@"CFBundleShortVersionString"]];

    // Do any additional setup after loading the view from its nib.
}
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
                [UIViewHelper showAlert:@"当前已是最新版本" target:self];
            }
        }else{
            [[iToast makeText:@"检查更新失败,请重试!"] show];
        }
    }];
}

-(void) viewWillAppear:(BOOL)animated{
    if(self.navigationController.isNavigationBarHidden){
        [self.navigationController setNavigationBarHidden:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(!self.navigationController.isNavigationBarHidden){
        [self.navigationController setNavigationBarHidden:YES];
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
