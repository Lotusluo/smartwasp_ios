//
//  MainViewController.m
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import "MainViewController.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "CommonTabController.h"
#import "SkillViewController.h"
#import "UserViewController.h"
#import "FinderViewController.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import "AppDelegate.h"
#import "JCGCDTimer.h"
#import "Reachability.h"
#import "UIViewHelper.h"
#import "NetDAO.h"
#import "Loading.h"
#import "ConfigBean.h"
#import "NSString+Extension.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)


@interface MainViewController ()<UIGestureRecognizerDelegate>

@end

@implementation MainViewController
- (instancetype)init{
    self = [super init];
    if(self){
        //tabbar标题
        NSArray *titleSources = @[NSLocalizedString(@"tab_dialog",nil),
                                  NSLocalizedString(@"tab_find",nil),
                                  NSLocalizedString(@"tab_skill",nil),
                                  NSLocalizedString(@"tab_home",nil),
                                  NSLocalizedString(@"tab_usr",nil)];
        
        NSArray *iconSources = @[@"icon_tab_dialog",
                                 @"icon_tab_find",
                                 @"icon_tab_skill",
                                 @"icon_tab_smart",
                                 @"icon_tab_mine"];
        
        NSArray *iconSelctedSources = @[@"icon_tab_dialog_selected",
                                        @"icon_tab_find_selected",
                                        @"icon_tab_skill_selected",
                                        @"icon_tab_smart_selected",
                                        @"icon_tab_mine_selected"];
      
        [self.tabBar setTintColor:  [UIColor colorWithHexString:@"#f6921e"]];
        //对话页
        CommonTabController *dialogVc = [[CommonTabController alloc] init];
        dialogVc.vcType = TALK;
        dialogVc.tag = @"TALK";
        [self addChildViewController:dialogVc];
        //发现页
        FinderViewController *finderVc = [[FinderViewController alloc] init];
        [self addChildViewController:finderVc];
        //技能页
        SkillViewController *skillVc = [[SkillViewController alloc] init];
        [self addChildViewController:skillVc];
        //家居页
        CommonTabController *homeVc = [[CommonTabController alloc] init];
        homeVc.vcType =  CONTROLLED_DEVICES;
        homeVc.tag = @"CONTROLLED_DEVICES";
        [self addChildViewController:homeVc];
        //我的页
        UserViewController *userVc = [[UserViewController alloc] init];
        [self addChildViewController:userVc];

        NSEnumerator *enumerator = self.viewControllers.objectEnumerator;
        UIViewController* vc;
        int i = 0;
        while (vc = [enumerator nextObject]) {
            vc.tabBarItem.title = titleSources[i];
            vc.tabBarItem.selectedImage = [UIImage imageNamed:iconSelctedSources[i]];
            vc.tabBarItem.image = [UIImage imageNamed:iconSources[i]];
            i++;
        }
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self gotConfig];
    // Do any additional setup after loading the view.
//    [JCGCDTimer timerTask:^{
//
//    } start:1 interval:0 repeats:NO async:NO];
    
}

//获取配置文件
-(void)gotConfig{
    __weak typeof(self) SELF = self;
    //获取新发现页数据
    [Loading show:nil];
    NSString *bosAPI = @"https://smartwasp.bj.bcebos.com/request/config";
    [[NetDAO sharedInstance] getBos:bosAPI callBack:^(BaseBean * _Nonnull cData) {
        [Loading dismiss];
        if(!cData.errCode){
            APPDELEGATE.configBean = [ConfigBean yy_modelWithDictionary:cData.data];
            if(APPDELEGATE.configBean && ![APPDELEGATE.configBean.appMainTip isEmpty]){
                [UIViewHelper showAlert:APPDELEGATE.configBean.appMainTip target:self];
            }
        }
    }];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [APPDELEGATE requestBindDevices];
    self.navigationController.navigationBar.hidden = YES;
}

//网络不可用
-(void)netNotReachable{
    for(UIViewController *vc in APPDELEGATE.rootNavC.viewControllers){
        if([NSStringFromClass(vc.class) containsString:@"AddDeviceViewController"]){
            return;
        }
    }
    [UIViewHelper showAlert:NSLocalizedString(@"no_internet", nil) target:self callBack:^{
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } negative:YES];
}

//网络可用
-(void)netReachable{
    if(APPDELEGATE.curDevice){
        [APPDELEGATE subscribeDeviceStatus];
        [APPDELEGATE subscribeMediaStatus];
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
