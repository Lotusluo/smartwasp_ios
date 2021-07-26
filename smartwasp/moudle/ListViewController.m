//
//  ListViewController.h
//  JXCategoryView
//
//  Created by luotao on 2021/7/26.
//

#import "ListViewController.h"
#import "ABUITableViewCell.h"
#import "SkillDetailViewController.h"

@implementation ListViewController

static NSString *const ID = @"ABUITableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellReuseIdentifier:ID];
    
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ABUITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
//    cell.bean = [self.lists objectAtIndex:indexPath.row];
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
