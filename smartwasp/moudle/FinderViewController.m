//
//  FinderViewController.m
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import "FinderViewController.h"
#import "AppDelegate.h"
#import "Toolbar.h"
#import "IFLYOSSDK.h"
#import "FindBean.h"
#import "NSObject+YYModel.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface FinderViewController ()
//工具栏
@property(nonatomic) Toolbar *toolbar;

@end

@implementation FinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initToolbar];
    //对选择的设备进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devSetObserver:)
                                                 name:@"devSetNotification"
                                               object:nil];
    [self devSetObserver:nil];
    [self reloadData];
    // Do any additional setup after loading the view from its nib.
}

//初始化自定义导航条
-(void) initToolbar{
    _toolbar = [Toolbar newView];
    [self.view addSubview:_toolbar];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //布局前重置一下toolbar的frame
    _toolbar.frame = CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, 49);
}

#pragma mark - 处理通知
-(void)devSetObserver:(NSNotification*)notification {
    NSLog(@"收到设备选择的消息通知");
    AppDelegate* app  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if(app.curDevice){
        [self.toolbar setDevName:app.curDevice.alias];
        [self.toolbar setDevStatus:app.curDevice.isOnLine];
    }else{
        [self.toolbar setEmpty];
    }
}

//重加载数据
-(void)reloadData{
    //获取发现页面数据
    if(APPDELEGATE.curDevice){
        [[IFLYOSSDK shareInstance] getMusicGroups:APPDELEGATE.curDevice.device_id statusCode:^(NSInteger statusCode) {
            if(statusCode != 200){
                [self loadDataEccur];
            }
            NSLog(@"状态码：%li",statusCode);
        } requestSuccess:^(id _Nonnull data) {
            FindBean *findBean = [FindBean yy_modelWithJSON:data];
            if(findBean){
                [self loadDataSucess:findBean];
            }else{
                [self loadDataEccur];
            }
        } requestFail:^(id _Nonnull data) {
            [self loadDataEccur];
        }];
    }
}

//加载数据遇到错误
-(void)loadDataSucess:(FindBean*)bean{
    NSLog(@"loadDataSucess:%@",bean);
}

//加载数据遇到错误
-(void)loadDataEccur{
    NSLog(@"loadDataEccur");
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
