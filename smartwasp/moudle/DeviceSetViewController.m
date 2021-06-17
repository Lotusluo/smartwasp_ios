//
//  DeviceSetViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/17.
//

#import "DeviceSetViewController.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "NormalToolbar.h"
#import "AppDelegate.h"
#import "IFLYOSSDK.h"
#import "Loading.h"
#import "NSObject+YYModel.h"
#import "NetDAO.h"
#import "BaseBean.h"
#import "SkillBean.h"
#import <Masonry.h>

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface DeviceSetViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NormalToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UIView *keepView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//音箱名称
@property (weak, nonatomic) IBOutlet UITextField *textField;
//音箱场景
@property (weak, nonatomic) IBOutlet UILabel *positionView;
//到期时间
@property (weak, nonatomic) IBOutlet UILabel *timeView;
//私有技能控件容器高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skillContainerHeight;
//私有技能控件容器
@property (weak, nonatomic) IBOutlet UIStackView *skillContainer;

@end

@implementation DeviceSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolBar.title = self.deviceBean.name;
    self.toolBar.titleColor = [UIColor blackColor];
    self.switchBtn.transform = CGAffineTransformMakeScale(0.75, 0.75);
    NEED_REFRESH_DEVICES_DETAIL = YES;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refresh];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat _height = self.skillContainerHeight.constant + 210 + self.keepView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,_height);
}

//界面根据数据改变
-(void)attachUI{
    if(self.deviceBean){
        self.textField.text = self.deviceBean.name;
        self.positionView.text = self.deviceBean.zone;
        self.timeView.text = self.deviceBean.music.value;
    }
}

//刷新讯飞数据
-(void)refresh{
    if(NEED_REFRESH_DEVICES_DETAIL){
        NSString *deviceID = self.deviceBean.device_id;
        [Loading show:nil];
        [[IFLYOSSDK shareInstance] getDeviceInfo:deviceID statusCode:
         ^(NSInteger statusCode) {
            NEED_REFRESH_DEVICES_DETAIL = NO;
            if(statusCode != 200){
                NSLog(@"加载失败");
            }
        } requestSuccess:^(id _Nonnull data) {
            [Loading dismiss];
            DeviceBean *device = [[DeviceBean alloc]init];
            [device setValuesForKeysWithDictionary:data];
            device.client_id = self.deviceBean.client_id;
            device.device_id = self.deviceBean.device_id;
            self.deviceBean = device;
            [self attachUI];
            [self innerRefresh:0];
        } requestFail:^(id _Nonnull data) {
            [Loading dismiss];
            NSLog(@"加载失败");
        }];
       
    }
}

//刷新私有数据
-(void)innerRefresh:(NSInteger) bindCount{
    if(bindCount == 0){
        [Loading show:nil];
    }
    NSString *deviceID = self.deviceBean.device_id;
    deviceID = [deviceID substringFromIndex:[deviceID rangeOfString:@"."].location + 1];
    //先请求私有技能
    [[NetDAO sharedInstance]
     post:@{@"uid":APPDELEGATE.user.user_id,
            @"clientId":self.deviceBean.client_id,
            @"deviceId":deviceID
     }
     path:@"api/getSkillList"
     callBack:^(BaseBean* _Nonnull cData) {
        if(cData.errCode == 0){
            [Loading dismiss];
            [self.skillContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            NSArray *skills = cData.data;
            self.skillContainerHeight.constant = 50 * skills.count;
            for(NSDictionary* dict in skills){
                SkillBean *skill = [SkillBean yy_modelWithDictionary:dict];
                UIView *skillView = [[[NSBundle mainBundle] loadNibNamed:@"SkillView" owner:nil options:nil] lastObject];
                ((UILabel*)skillView.subviews[0]).text = skill.shopName;
                [self.skillContainer addArrangedSubview:skillView];
                [skillView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(@50);
                }];
            }
        }else if(cData.errCode == 408){
            //重新绑定再获取技能
        }else{
            [Loading dismiss];
            NSLog(@"技能加载错误");
        }
    }];
}

//持续交互状态改变
- (IBAction)onPrimaryAction:(id)sender {
    NSLog(@"onPrimaryAction");
}

//解除绑定点击
- (IBAction)onUnbindClick:(id)sender {
    NSLog(@"onUnbindClick");
}

//设备位置选择
- (IBAction)onPositionClick:(id)sender {
    NSLog(@"onPositionClick");
}

//音乐畅听点击
- (IBAction)onMusicClick:(id)sender {
    NSLog(@"onMusicClick");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 实现UITextFieldDelegate委托协议方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


//静态方式生成ViewController
+(DeviceSetViewController *) createNewPage:(DeviceBean *) deviceBean{
    DeviceSetViewController *dvc = [[DeviceSetViewController alloc] initWithNibName:@"DeviceSetViewController" bundle:nil];
    dvc.deviceBean = deviceBean;
    return dvc;
}

@end




@implementation BottomLineView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithHexString:@"#8A8A8A"] setStroke];
    CGContextMoveToPoint(context, 20, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(context);
}

@end