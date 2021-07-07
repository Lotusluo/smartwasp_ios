//
//  UsrCenterViewController.m
//  smartwasp
//
//  Created by tao luo on 2021/6/20.
//

#import "UsrCenterViewController.h"
#import "AppDelegate.h"
#import "AppDelegate+Global.h"
#import "UIViewHelper.h"
#import "ConfigDAO.h"
#import "iToast.h"
#import "Loading.h"
#import "JCGCDTimer.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface UsrCenterViewController ()<IFLYOSsdkLoginDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usrPhone;

@end

@implementation UsrCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人中心";
    self.tableView.rowHeight = 44;
    self.usrPhone.text = APPDELEGATE.user.phone;
//    self.tableView.backgroundView = ({
//    UIView * view = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    view.backgroundColor = [UIColor redColor];
//    view;
//    });
    // Do any additional setup after loading the view from its nib.
}

#pragma mark --UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 2 ? 40 : 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;{
    static NSString *headerSectionID = @"headerSectionID";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerSectionID];
    if (headerView == nil){
        headerView =  UITableViewHeaderFooterView.new;
        headerView.contentView.backgroundColor = [UIColor lightTextColor];
    }
    return headerView;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    UITouch *touch=[touches anyObject];
//    CGPoint cureentTouchPosition=[touch locationInView:self.TableView];
//    NSIndexPath *indexPath=[self.TableView indexPathForRowAtPoint:cureentTouchPosition];
//    NSLog(@"section----%li,----row---%li",(long)indexPath.section,(long)indexPath.row);
    if(indexPath.section == 1){
        //用户码
        [UIViewHelper showAlert:APPDELEGATE.user.user_id target:self callBack:^{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = APPDELEGATE.user.user_id;
            [[iToast makeText:@"已复制到剪贴板!"] show];
        } positiveTxt:@"复制" negativeTxt:@"确定"];
    }else if(indexPath.section == 2){
        //退出登陆
        [UIViewHelper showAlert:@"是否退出登陆？" target:self callBack:^{
            [Loading show:nil];
            [[IFLYOSSDK shareInstance] logout:self];
        } negative:YES];
    }
}


/**
 *  注销成功
 */
-(void)onLogoutSuccess{
    [Loading dismiss];
    [[ConfigDAO sharedInstance] remove:@"usr"];
    [APPDELEGATE toLogin];
}

/**
 *  注销失败
 */
-(void)onLogoutFailed:(NSInteger) type error:(NSError *) error{
    [Loading dismiss];
    [[iToast makeText:@"退出登陆失败，请重试!"] show];
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
