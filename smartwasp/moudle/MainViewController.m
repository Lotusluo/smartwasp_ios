//
//  MainViewController.m
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import "MainViewController.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "CommonTabController.h"
#import "FinderViewController.h"
#import "UserViewController.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>

@interface MainViewController ()

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
        CommonTabController *skillVc = [[CommonTabController alloc] init];
        skillVc.vcType = SKILLS;
        skillVc.tag = @"SKILLS";
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{

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
