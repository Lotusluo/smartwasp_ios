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
#import "iToast.h"
#import "NSObject+YYModel.h"
#import "NetDAO.h"
#import "BaseBean.h"
#import "SkillBean.h"
#import <Masonry.h>
#import "UIViewHelper.h"
#import "UIView+Extension.h"
#import "SkillDetailViewController.h"
#import "GSMonitorKeyboard.h"
#import "WebPageViewController.h"
#import "UIViewHelper.h"
#import "NetDAO.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define MaxLength 15

@interface DeviceSetViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NormalToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UIView *keepView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//音箱名称
@property (weak, nonatomic) IBOutlet UITextField *deviceName;
//音箱场景
@property (weak, nonatomic) IBOutlet UITextField *deviceZone;
//到期时间
@property (weak, nonatomic) IBOutlet UILabel *timeView;
//私有技能控件容器高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skillContainerHeight;
//私有技能控件容器
@property (weak, nonatomic) IBOutlet UIStackView *skillContainer;
//是否刷新设备详情页
@property (nonatomic)BOOL NEED_REFRESH_DETAIL;

@end

@implementation DeviceSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.NEED_REFRESH_DETAIL = YES;
    self.toolBar.title = self.deviceBean.name;
    self.toolBar.titleColor = [UIColor blackColor];
    self.switchBtn.transform = CGAffineTransformMakeScale(0.75, 0.75);
    [self.deviceName addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.deviceZone addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self canClick];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.NEED_REFRESH_DETAIL){
        [self refresh];
        self.NEED_REFRESH_DETAIL = NO;
    }
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat _height = self.skillContainerHeight.constant + 210 + self.keepView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,_height);
}

//界面根据数据改变
-(void)attachUI{
    if(self.deviceBean){
        self.deviceName.text = self.deviceBean.alias;
        self.deviceZone.text = self.deviceBean.zone;
        self.timeView.text = self.deviceBean.music.value;
        self.switchBtn.on = self.deviceBean.continous_mode;
    }
}

//刷新讯飞数据
-(void)refresh{
    NSString *deviceID = self.deviceBean.device_id;
    __weak typeof(self) SELF = self;
    [Loading show:nil];
    [[IFLYOSSDK shareInstance] getDeviceInfo:deviceID statusCode:
     ^(NSInteger statusCode) {
        if(statusCode != 200){
            NSLog(@"加载失败");
        }
    } requestSuccess:^(id _Nonnull data) {
        [Loading dismiss];
        DeviceBean *device = [DeviceBean yy_modelWithDictionary:data];
        device.client_id = SELF.deviceBean.client_id;
        device.device_id = SELF.deviceBean.device_id;
        SELF.deviceBean = device;
        [SELF attachUI];
        [SELF innerRefresh:0];
    } requestFail:^(id _Nonnull data) {
        [Loading dismiss];
        NSLog(@"加载失败");
    }];
}

//刷新私有数据
-(void)innerRefresh:(NSInteger) bindCount{
    if(bindCount == 0){
        [Loading show:nil];
    }
    __weak typeof(self) SELF = self;
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
            [SELF.skillContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            SELF.skillArray = [NSArray yy_modelArrayWithClass:SkillBean.class json:cData.data];
            SELF.skillContainerHeight.constant = 50 * SELF.skillArray.count;
            NSInteger index = 0;
            for(SkillBean* skill in SELF.skillArray){
                UIView *skillView = [UIViewHelper loadNibByName:@"SkillView"];
                skillView.tag = index++;
                [UIViewHelper attachText:skill.shopName widget:skillView.subviews[0]];
                [UIViewHelper attachClick:skillView target:SELF action:@selector(doTapMethod:)];
                skillView.height = 50;
                [SELF.skillContainer addArrangedSubview:skillView];
            }
        }else if(cData.errCode == 408){
            //重新绑定再获取技能
            [Loading dismiss];
            if(bindCount <= 1){
                NSString *deviceID = SELF.deviceBean.device_id;
                deviceID = [deviceID substringFromIndex:[deviceID rangeOfString:@"."].location + 1];
                [[NetDAO sharedInstance] post:@{@"clientIds":self.deviceBean.client_id,
                                                @"deviceIds":deviceID,
                                                @"uid":APPDELEGATE.user.user_id}
                                         path:@"api/bind"  callBack:^(BaseBean * _Nonnull cData) {
                    if(!cData.errCode ){
                        [SELF innerRefresh:bindCount + 1];
                    }
                }];
            }
        }else{
            [Loading dismiss];
        }
    }];
}

-(void)doTapMethod:(UITapGestureRecognizer*)sender{
    if(![self canClick])
        return;
    NSInteger index = sender.view.tag;
    if(self.skillArray){
        SkillBean *skillBean = self.skillArray[index];
        SkillDetailViewController *svc = [SkillDetailViewController createNewPage:skillBean];
        [self.navigationController pushViewController:svc animated:YES];
    }
}

//持续交互状态改变
- (IBAction)onPrimaryAction:(id)sender {
    if(![self canClick])
        return;
    [Loading show:nil];
    BOOL exceptValue = self.switchBtn.on;
    __weak typeof(self) SELF = self;
    [[IFLYOSSDK shareInstance] setDeviceAlias:self.deviceBean.device_id alias:nil continousMode:exceptValue childrenMode:nil zone:nil statusCode:^(NSInteger code) {
        [Loading dismiss];
    } requestSuccess:^(id _Nonnull data) {
    } requestFail:^(id _Nonnull data) {
        SELF.switchBtn.on = !exceptValue;
        [[iToast makeText:@"修改失败,请重试!"] show];
    }];
}

//解除绑定点击
- (IBAction)onUnbindClick:(id)sender {
    if(![self canClick])
        return;
    __weak typeof(self) SELF = self;
    [UIViewHelper showAlert:@"是否解绑该设备？" target:self callBack:^{
        [Loading show:nil];
        [[IFLYOSSDK shareInstance] deleteUserDevice:self.deviceBean.device_id
                                         statusCode:^(NSInteger code) {

        } requestSuccess:^(id _Nonnull data) {
            //解绑成功后，如果当前
            if([APPDELEGATE.curDevice isEqual:SELF.deviceBean]){
                APPDELEGATE.curDevice = nil;
            }
            NEED_MAIN_REFRESH_DEVICES = YES;
            NSString *deviceID = SELF.deviceBean.device_id;
            deviceID = [deviceID substringFromIndex:[deviceID rangeOfString:@"."].location + 1];
            //解绑成功,开始内部解绑
            [[NetDAO sharedInstance]
             post:@{@"uid":APPDELEGATE.user.user_id,
                    @"clientId":self.deviceBean.client_id,
                    @"deviceId":deviceID
             }
             path:@"api/unbind"
             callBack:^(BaseBean* _Nonnull cData) {
                [Loading dismiss];
                [SELF.navigationController popViewControllerAnimated:YES];
            }];
        } requestFail:^(id _Nonnull data) {
            [Loading dismiss];
            [[iToast makeText:@"解绑失败,请重试!"] show];
        }];
    } negative:YES];
}

//音乐畅听点击
- (IBAction)onMusicClick:(id)sender {
    if(![self canClick])
        return;
    self.NEED_REFRESH_DETAIL = YES;
    WebPageViewController *nvc = [WebPageViewController createNewPageWithUrl:self.deviceBean.music.redirect_url];
    [self.navigationController pushViewController:nvc animated:YES];
}

-(BOOL)canClick{
    GSMonitorKeyboard *monitor = [GSMonitorKeyboard sharedMonitorMethod];
    if (monitor.showKeyboard) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

//销毁
-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField == self.deviceName){
        //音箱名称修改
        NSLog(@"name modify");
        [Loading show:nil];
        [[IFLYOSSDK shareInstance] setDeviceAlias:self.deviceBean.device_id alias:textField.text continousMode:nil childrenMode:nil zone:nil statusCode:^(NSInteger code) {
            [Loading dismiss];
        } requestSuccess:^(id _Nonnull data) {
            NEED_MAIN_REFRESH_DEVICES = YES;
        } requestFail:^(id _Nonnull data) {
            [[iToast makeText:@"修改失败,请重试!"] show];
        }];
    }else if(textField == self.deviceZone){
        //音箱位置修改
        NSLog(@"position modify");
        [Loading show:nil];
        [[IFLYOSSDK shareInstance] setDeviceAlias:self.deviceBean.device_id alias:nil continousMode:nil childrenMode:nil zone:textField.text statusCode:^(NSInteger code) {
            [Loading dismiss];
        } requestSuccess:^(id _Nonnull data) {
            NEED_MAIN_REFRESH_DEVICES = YES;
        } requestFail:^(id _Nonnull data) {
            [[iToast makeText:@"修改失败,请重试!"] show];
        }];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self isInputRuleNotBlank:string] || [string isEqualToString:@""]) {
        //当输入符合规则和退格键时允许改变输入框
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldChanged:(UITextField *)textField {
    NSString *toBeString = textField.text;
    if (![self isInputRuleAndBlank:toBeString]) {
        textField.text = [self disable_emoji:toBeString];
        return;
    }
    
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 获取当前键盘输入模式
    //简体中文输入,第三方输入法（搜狗）所有模式下都会显示“zh-Hans”
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            NSString *getStr = [self getSubString:toBeString];
            if(getStr && getStr.length > 0) {
                textField.text = getStr;
            }
        }
    } else{
        NSString *getStr = [self getSubString:toBeString];
        if(getStr && getStr.length > 0) {
            textField.text= getStr;
        }
    }
}


/**
 * 字母、数字、中文正则判断（不包括空格）
 */
- (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        NSString *other = @"➋➌➍➎➏➐➑➒";
        unsigned long len=str.length;
        for(int i=0;i<len;i++)
        {
            unichar a=[str characterAtIndex:i];
            if(!((isalpha(a))
                 ||(isalnum(a))
                 ||((a=='_') || (a == '-'))
                 ||((a >= 0x4e00 && a <= 0x9fa6))
                 ||([other rangeOfString:str].location != NSNotFound)
                 ))
                return NO;
        }
        return YES;
        
    }
    return isMatch;
}
/**
 * 字母、数字、中文正则判断（包括空格）（在系统输入法中文输入时会出现拼音之间有空格，需要忽略，当按return键时会自动用字母替换，按空格输入响应汉字）
 */
- (BOOL)isInputRuleAndBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

/**
 *  过滤字符串中的emoji
 */
- (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}


-(NSString *)getSubString:(NSString*)string {
    if (string.length > MaxLength) {
        return [string substringToIndex:MaxLength];
    }
    return nil;
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


@implementation NSScrollView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

-(BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}


@end
