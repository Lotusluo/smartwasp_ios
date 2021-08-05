//
//  ListViewController.h
//  JXCategoryView
//
//  Created by luotao on 2021/7/26.
//

#import "ListViewController.h"
#import "ABUITableViewCell.h"
#import "SkillDetailViewController.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"

#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define NAVI_HEIGHT (self.navigationController.navigationBar.frame.size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface ListViewController()

//替代透明导航栏背景
@property(nonatomic,strong)UIView *mask;

@end

@implementation ListViewController

static NSString *const ID = @"ABUITableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellReuseIdentifier:ID];
    [self.view addSubview:self.mask];
}

#pragma mark --bgLayer懒加载
-(UIView*)mask{
    if(!_mask){
        _mask = [UIView new];
        _mask.backgroundColor = [UIColor colorWithHexString:@"#F9F9F9"];
    }
    return _mask;
}

#pragma mark --UIUIScrollViewDelegate 协议方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat _H = NAVI_HEIGHT + STATUS_HEIGHT;
    self.mask.frame = CGRectMake(0, scrollView.contentOffset.y, SCREEN_WIDTH, _H);
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SkillBean *skillBean = self.lists[indexPath.row];
    ABUITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setTitle:skillBean.skillName];
    [cell setSubtitle:skillBean.skillDesc];
    [cell setIcon:skillBean.icon];
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SkillBean *bean = self.lists[indexPath.row];
    SkillDetailViewController *svc = [SkillDetailViewController createNewPage:bean];
    [self.navigationController pushViewController:svc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}


@end
