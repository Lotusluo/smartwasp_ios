//
//  UsrCenterViewController.m
//  smartwasp
//
//  Created by tao luo on 2021/6/20.
//

#import "UsrCenterViewController.h"

@interface UsrCenterViewController ()

@end

@implementation UsrCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人中心";
    self.tableView.rowHeight = 44;
//    self.tableView.backgroundView = ({
//    UIView * view = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    view.backgroundColor = [UIColor redColor];
//    view;
//    });
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
