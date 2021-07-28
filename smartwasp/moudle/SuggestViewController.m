//
//  SuggestViewController.m
//  smartwasp
//
//  Created by luotao on 2021/7/27.
//

#import "SuggestViewController.h"
#import "iToast.h"
#import "NetDAO.h"
#import "Loading.h"
#import "AppDelegate.h"
#import "UIViewHelper.h"
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface SuggestViewController ()<UITextFieldDelegate>
//意见与建议输入框
@property (weak, nonatomic) IBOutlet UITextField *suggestTxt;
//邮箱地址输入框
@property (weak, nonatomic) IBOutlet UITextField *emailTxt;

@end

@implementation SuggestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"suggest", nil);
    // Do any additional setup after loading the view from its nib.
}

//一键反馈
- (IBAction)onSuggestClick:(id)sender {
    NSString *suggest = [self tempString:self.suggestTxt.text];
    NSString *email = [self tempString:self.emailTxt.text];
    if([suggest isEqualToString:@""]){
        [[iToast makeText:NSLocalizedString(@"input_err", nil)] show];
        return;
    }
    BOOL isEmail = [self tempEmail:email];
    if([email isEqualToString:@""] || !isEmail){
        [[iToast makeText:NSLocalizedString(@"email_err", nil)] show];
        return;
    }
    [Loading show:nil];
    [[NetDAO sharedInstance] post:@{@"uid":APPDELEGATE.user.user_id,
                                    @"proId":@"0",
                                    @"text":suggest,
                                    @"mail":email}
                             path:@"api/userFeed"  callBack:^(BaseBean * _Nonnull cData) {
        [Loading dismiss];
        if(!cData.errCode){
            [[iToast makeText:NSLocalizedString(@"suggest_ok", nil)] show];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [[iToast makeText:NSLocalizedString(@"suggest_err", nil)] show];
        }
    }];
}

//去除字符串的空格与换行符
-(NSString*)tempString:(NSString*)inputTxt{
    NSString *handleTxt;
    handleTxt = [inputTxt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除首位空格
    handleTxt = [handleTxt stringByReplacingOccurrencesOfString:@" "withString:@""];//去除中间空格
    handleTxt = [handleTxt stringByReplacingOccurrencesOfString:@"\n"withString:@""];//去除换行符
    return handleTxt;
}

#pragma mark -- 邮箱地址正则表达式
- (BOOL)tempEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
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
