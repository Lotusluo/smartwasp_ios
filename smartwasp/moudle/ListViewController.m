//
//  ListViewController.m
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/8.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "ListViewController.h"
#import "MoreMusicItemCell.h"
#import "ItemViewController.h"

@implementation ListViewController

static NSString *const ID = @"MoreMusicItemCell";

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
    MoreMusicItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    cell.bean = [self.lists objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ItemBean *bean = self.lists[indexPath.row];
    ItemViewController *ivc =  [ItemViewController createNewPage:bean];
    [self.navigationController pushViewController:ivc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark - JXCategoryListContentViewDelegate

/**
 实现 <JXCategoryListContentViewDelegate> 协议方法，返回该视图控制器所拥有的「视图」
 */
- (UIView *)listView {
    return self.view;
}

@end
