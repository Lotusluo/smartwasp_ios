//
//  FinderViewController.m
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import "FinderViewController.h"
#import "Toolbar.h"
#import "IFLYOSSDK.h"
#import "FindBean.h"
#import "NSObject+YYModel.h"
#import <Masonry.h>
#import "PageLineLayout.h"
#import "UIImageView+WebCache.h"
#import "JXCategoryView.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "HWHeadRefresh.h"
#import "GroupView.h"
#import "WebPageViewController.h"
#import "ItemViewController.h"
#import "MusicPlayViewController.h"
#import "AppDelegate.h"
#import "AppDelegate+Global.h"
#import "Loading.h"
#import "ItemBean.h"
#import "UIViewHelper.h"
#import "iToast.h"
#import "ItemMoreViewController.h"
#import "NetDAO.h"
#import "ABUITableViewCell.h"
#import "ListViewController.h"
#import "SkillDetailViewController.h"
#import "JCGCDTimer.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define APAGE_SIZE (CGSizeMake(SCREEN_WIDTH - 30,SCREEN_WIDTH * 0.4))

@interface FinderViewController ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate>

//工具栏
@property(nonatomic,strong) Toolbar *toolbar;
//滚动控件
@property (strong, nonatomic) UIScrollView *scrollView;
//Banner图
@property (strong, nonatomic) UICollectionView *collectionView;
//视图列表
@property (strong, nonatomic) UIScrollView *tableViewFather;
@property (nonatomic,strong) UITableView *tableView;
//引导器
@property (strong,nonatomic) UIPageControl *pageCtrl;
//发现页数据
@property (nonatomic,strong) FindBean *findBean;
//刷新控件
@property (nonatomic,strong) HWHeadRefresh *headerView;

@property (nonatomic) NSString *looperTaskName;

@end

@implementation FinderViewController

static NSString *const ID = @"ABUITableViewCell";
static NSString *const ID1 = @"FinderHeaderCell";
static NSString *const ID2 = @"FindBannerCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加toolbar
    [self.view addSubview:self.toolbar];
    //添加刷新控件
    [self.view addSubview:self.scrollView];
    // Do any additional setup after loading the view from its nib.
}

//对子控件进行重新布局
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _toolbar.frame = CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, 49);
    //设置scrollView约束
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.top.equalTo(self.toolbar.mas_bottom);
        CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
    }];
}

#pragma mark - 处理通知
-(void)devSetCallback:(DeviceBean* __nullable) device {
    self.NEED_REFRESH_UI = YES;
    [self reloadData:device];
}

//处理设备媒体状态通知
-(void)mediaSetCallback:(MusicStateBean* __nullable) musicStateBean{
    if (self.isViewLoaded && self.view.window){
        if(musicStateBean && musicStateBean.isPlaying){
            [self.toolbar startJump];
            return;
        }
    }
    [self.toolbar stopJump];
}

//设备在线状态变更
-(void)onLineChangedCallback{
    [self.toolbar update];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.toolbar update];
    if(self.NEED_REFRESH_UI){
        [self reloadData:APPDELEGATE.curDevice];
    }
}

//重加载数据
-(void)reloadData:(DeviceBean *)device{
    if (!self.isViewLoaded || !self.view.window){
        return;
    }
    __weak typeof(self) SELF = self;
    //设置是否空设备状态
    UIView *emptyView = [self.view viewWithTag:1001];
    emptyView.hidden = device != nil;
    self.toolbar.device = device;
    if(device){
        //获取新发现页数据
        BOOL flag = self.findBean == nil;
        if(flag){
            [Loading show:nil];
        }
        NSString *bosAPI = @"https://smartwasp.bj.bcebos.com/request/newFinder";
        [[NetDAO sharedInstance] getBos:bosAPI callBack:^(BaseBean<FindBean*> * _Nonnull cData) {
            SELF.NEED_REFRESH_UI = NO;
            [SELF.headerView hw_endRefreshState];
            if(flag){
                [Loading dismiss];
            }
            if(!cData.errCode){
                SELF.findBean = [FindBean yy_modelWithJSON:cData.data];
                if(SELF.findBean){
                    //有发现页数据才算成功
                    [SELF loadDataSucess];
                    return;
                }
            }
            [SELF loadDataEccur:YES];
        }];
    }else{
        //暂无设备
        [self.view bringSubviewToFront:emptyView];
        [self loadDataEccur:NO];
    }
}

//加载数据成功
-(void)loadDataSucess{
    //清空容器
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //刷新Banner数据
    [self.collectionView reloadData];
    [JCGCDTimer canelTimer:self.looperTaskName];
    __weak typeof(self) SELF = self;
    self.looperTaskName = [JCGCDTimer timerTask:SELF selector:@selector(looperTask) start:5 interval:5 repeats:YES async:NO];
    [self.scrollView addSubview:self.collectionView];
    [self.scrollView addSubview:self.pageCtrl];
    //对scrollView进行约束
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(APAGE_SIZE.width);
        make.height.mas_equalTo(APAGE_SIZE.height);
        make.centerX.equalTo(self.view);
        //IOS 11.4不设置会出现布局紊乱
        make.top.mas_equalTo(0);
    }];
    self.pageCtrl.numberOfPages = self.findBean.banners.count;
    self.pageCtrl.currentPage = 0;
    //对指示器进行约束
    [self.pageCtrl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.collectionView);
        make.height.equalTo(@50);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.collectionView).offset(10);
    }];
    
    [self.tableView reloadData];
    [self.scrollView addSubview:self.tableView];
    //对tableview进行约束
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(20);
        make.width.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
    }];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.scrollView.frame.size.height + 20 + APAGE_SIZE.height);
}

/**
 加载数据遇到错误
 @param flag 是否弹出重新请求发现页数据弹出框
 */
-(void)loadDataEccur:(BOOL)flag{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.findBean = nil;
    if(flag){
        [UIViewHelper showAlert:NSLocalizedString(@"load_data_err", nil)
                         target:self callBack:^{
            [self reloadData:APPDELEGATE.curDevice];}
                    positiveTxt:NSLocalizedString(@"retry_btn", nil)
                    negativeTxt:NSLocalizedString(@"cancel_btn", nil)];
    }
}

//banner滚动回调
-(void)looperTask{
    if (self.isViewLoaded  && self.view.window){
        NSInteger nowIndex = (self.pageCtrl.currentPage + 1 + self.findBean.banners.count) % self.findBean.banners.count;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:nowIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        self.pageCtrl.currentPage = nowIndex;
    }
}

/***********************************Start UIScrollViewDelegate代理实现**********************************/

#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if([scrollView isKindOfClass:UICollectionView.class]){
        BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (scrollToScrollStop) {
            int page = floor(scrollView.contentOffset.x / (APAGE_SIZE.width + 30));
            if(self.pageCtrl){
                self.pageCtrl.currentPage = page;
                [JCGCDTimer canelTimer:self.looperTaskName];
                __weak typeof(self) SELF = self;
                self.looperTaskName = [JCGCDTimer timerTask:SELF selector:@selector(looperTask) start:5 interval:5 repeats:YES async:NO];
            }
        }
        return;
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger zeroValue = APAGE_SIZE.height + 20 + 0.5;
    if (scrollView == self.scrollView) {
        if (self.tableView.contentOffset.y > 0) {
            // header已经消失，开始滚动下面的_table，并让_scroll不动
            self.scrollView.contentOffset = CGPointMake(0, zeroValue);
        }
        if (self.scrollView.contentOffset.y < zeroValue) {
            // header已经显示出来，重置_table.contentOffset为0
            self.tableView.contentOffset = CGPointZero;
        }
    }
    else if (scrollView == self.tableView) {
        if (self.scrollView.contentOffset.y < zeroValue) {
            // header还没有消失，那么_table.contentOffset一直为0
            self.tableView.contentOffset = CGPointZero;
            self.tableView.showsVerticalScrollIndicator = NO;
        }
        else {
            // header已经消失
            self.scrollView.contentOffset = CGPointMake(0, zeroValue);
            self.tableView.showsVerticalScrollIndicator = YES;
        }
    }
}

/***********************************End UIScrollViewDelegate代理实现**********************************/

/***********************************Start UICollectionView代理实现**********************************/

#pragma mark --UICollectionViewDelegate
-(void)collectionView:( UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    BannerBean *bannerBean = self.findBean.banners[indexPath.row];
    WebPageViewController *newPage = [WebPageViewController createNewPageWithUrl:bannerBean.url];
    [self.navigationController pushViewController:newPage animated:YES];
}

#pragma mark --UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.findBean.banners.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    UIImageView *imageView = [cell.subviews objectAtIndex:0];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.findBean.banners[index].image]];
    return cell;
}

/***********************************End UICollectionView代码**********************************/

/***********************************Start UITableViewDelegate代理实现**********************************/
#pragma mark --UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return indexPath.section > 0 ? UITableViewAutomaticDimension : 0;
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isMemberOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *tfView = (UITableViewHeaderFooterView*)view;
        tfView.tintColor = self.view.backgroundColor;
        tfView.contentView.backgroundColor = self.view.backgroundColor;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID1];
    NSString *key = self.findBean.abbrs[section];
    for(UIView *child in headerView.subviews){
        if([child isKindOfClass:UILabel.class]){
            UILabel *title = (UILabel*)child;
            title.text = key;
        }else if([child isKindOfClass:UIButton.class]){
            NSArray<SkillBean*> *lists = self.findBean.map[key];
            UIButton *moreBtn = (UIButton*)child;
            moreBtn.hidden = lists.count <= 1;
            moreBtn.tag = section;
            [moreBtn addTarget:self action:@selector(onMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return headerView;
}

/***********************************End UITableViewDelegate代码**********************************/

/***********************************Start UICollectionViewDataSource代理实现**********************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.findBean.abbrs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = self.findBean.abbrs[section];
    NSArray<SkillBean*> *lists = self.findBean.map[key];
    return lists.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;{
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = self.findBean.abbrs[indexPath.section];
    NSArray<SkillBean*> *lists = self.findBean.map[key];
    SkillBean *skillBean = lists[indexPath.row];
    ABUITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setTitle:skillBean.skillName];
    [cell setSubtitle:skillBean.skillDesc];
    [cell setIcon:skillBean.icon];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = self.findBean.abbrs[indexPath.section];
    NSArray<SkillBean*> *lists = self.findBean.map[key];
    SkillBean *skillBean = lists[indexPath.row];
    SkillDetailViewController *svc = [SkillDetailViewController createNewPage:skillBean];
    [self.navigationController pushViewController:svc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


/***********************************End UICollectionViewDataSource代理实现**********************************/

//刷新按钮点击
- (IBAction)onRefreshClick:(id)sender {
    [Loading show:nil];
    NEED_MAIN_REFRESH_DEVICES = YES;
    [APPDELEGATE requestBindDevices];
}

//header更多按钮点击
-(void)onMoreBtnClick:(id)sender{
    UIButton *target = sender;
    __weak typeof(self) SELF = self;
    //获取新发现页数据
    [Loading show:nil];
    NSString *key = self.findBean.abbrs[target.tag];
    NSString *bosAPI = @"https://smartwasp.bj.bcebos.com/request/newFinder%u";
    bosAPI = [NSString stringWithFormat:bosAPI,target.tag + 1];
    [[NetDAO sharedInstance] getBos:bosAPI callBack:^(BaseBean * _Nonnull cData) {
        [Loading dismiss];
        if(!cData.errCode){
            NSArray<SkillBean*> *lists = [NSArray yy_modelArrayWithClass:SkillBean.class json:cData.data];
            if(lists.count > 0){
                UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
                ListViewController *lvc = [board instantiateViewControllerWithIdentifier: @"ListViewController"];
                lvc.lists = lists;
                lvc.title = key;
                [SELF.navigationController pushViewController:lvc animated:YES];
                return;
            }
        }
        [[iToast makeText:NSLocalizedString(@"retry", nil)] show];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark --collectionView懒加载
-(UICollectionView*) collectionView{
    if(!_collectionView){
        PageLineLayout *lineLayout = [PageLineLayout new];
        lineLayout.itemSize = APAGE_SIZE;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:lineLayout];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        [_collectionView registerNib:[UINib nibWithNibName:ID2 bundle:nil] forCellWithReuseIdentifier:ID];
    }
    return _collectionView;
}

#pragma mark --tableCiew懒加载
-(UITableView*) tableView{
    if(!_tableView){
        //建立一个scrollview
        _tableViewFather = [UIScrollView new];
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        //注册头控件
        [_tableView registerNib:[UINib nibWithNibName:ID1 bundle:nil] forHeaderFooterViewReuseIdentifier:ID1];
        //注册元素控件
        [_tableView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellReuseIdentifier:ID];
//        [_tableViewFather addSubview:_tableView];
//        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(_tableViewFather);
//            make.height.equalTo(_tableViewFather);
//        }];
    }
    return _tableView;
}

#pragma mark --HWHeadRefresh懒加载
-(HWHeadRefresh*) headerView{
    if(!_headerView){
        _headerView = HWHeadRefresh.new;
        __weak typeof(self) SELF = self;
        [_headerView hw_addFooterRefreshWithView:_scrollView hw_footerRefreshBlock:^{
            [JCGCDTimer timerTask:^{
                SELF.NEED_REFRESH_UI = YES;
                [SELF reloadData:APPDELEGATE.curDevice];
            } start:1 interval:0 repeats:NO async:NO];
        }];
        [_scrollView addSubview:self.headerView];
    }
    return _headerView;
}

#pragma mark --指示器懒加载
-(UIPageControl*) pageCtrl{
    if(!_pageCtrl){
        _pageCtrl = UIPageControl.new;
        _pageCtrl.pageIndicatorTintColor =  [UIColor lightGrayColor];
        _pageCtrl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageCtrl.enabled = NO;
    }
    return _pageCtrl;
}

#pragma mark --Toolbar懒加载
-(Toolbar*) toolbar{
    if(!_toolbar){
        _toolbar = [Toolbar newView];
        _toolbar.canSearch = YES;
    }
    return _toolbar;
}

#pragma mark --ScrollView懒加载
-(UIScrollView*) scrollView{
    if(!_scrollView){
        _scrollView = [EGOScrollView new];
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    return _scrollView;
}

@end
