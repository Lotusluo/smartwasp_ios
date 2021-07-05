//
//  WifiInfoViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/25.
//

#import "WifiInfoViewController.h"
#import "UIViewHelper.h"
#import "iToast.h"
#import "PrevBindViewController.h"

@interface WifiInfoViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
//密码可视化控件
@property (weak, nonatomic) IBOutlet UIImageView *eyeView;
//wifi名称
@property (weak, nonatomic) IBOutlet UITextField *wifiName;
//wifi密码
@property (weak, nonatomic) IBOutlet UITextField *wifiPwd;

@end

@implementation WifiInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wifiName.text = self.ssid;
    [UIViewHelper attachClick:self.eyeView target:self action:@selector(onEyeViewClick)];
    // Do any additional setup after loading the view from its nib.
}


-(void)onEyeViewClick{
    self.eyeView.highlighted = !self.eyeView.isHighlighted;
    self.wifiPwd.secureTextEntry = self.eyeView.highlighted;
}

//下一步
- (IBAction)onNextClick:(id)sender {
    [self.view endEditing:YES];
    NSString *wifiNameTxt = self.wifiName.text;
    NSString *pwdTxt = self.wifiPwd.text;
    if(!wifiNameTxt.length || !pwdTxt.length || pwdTxt.length < 8){
        [[iToast makeText:@"Wi-Fi信息错误，请重试！"] show];
        return;
    }
    PrevBindViewController *pvc = PrevBindViewController.new;
    pvc.mBindType = NO_SCREEN_TYPE;
    SSID = wifiNameTxt;
    PWD = pwdTxt;
    [self.navigationController pushViewController:pvc animated:YES];
}

//返回
- (IBAction)onBackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
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
