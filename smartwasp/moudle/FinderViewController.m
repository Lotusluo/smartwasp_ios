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
#import "Loading.h"
#import "UIViewHelper.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)

#define APAGE_SIZE (CGSizeMake(SCREEN_WIDTH - 30,SCREEN_WIDTH * 0.27))
#define VIEW_GAP 10
#define PAYVIEW_HEIGHT 30
#define CATEGORYVIEW_HEIGHT 40

@interface FinderViewController ()<
UIScrollViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
JXCategoryViewDelegate,
ISelectedDelegate>
//工具栏
@property(nonatomic) Toolbar *toolbar;
//滚动控件
@property (strong, nonatomic) UIScrollView *scrollView;
//Banner图
@property (strong, nonatomic)  UICollectionView *collectionView;
@property (strong, nonatomic)  PageLineLayout *lineLayout;
@property (strong,nonatomic) UIPageControl *pageCtrl;
//指示器
@property (strong,nonatomic) JXCategoryTitleView *categoryView;
//发现页数据
@property (nonatomic,strong)FindBean *findBean;
//刷新控件
@property (nonatomic,strong) HWHeadRefresh *headerView;
//组布局垂直控件
@property (nonatomic,strong) UIStackView *verticalLayout;

@end

@implementation FinderViewController

static NSString *const ID = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加toolbar
    _toolbar = [Toolbar newView];
    _toolbar.canSearch = YES;
    [self.view addSubview:_toolbar];
    //添加刷新控件
    self.scrollView = [UIScrollView new];
    [self.view addSubview:_scrollView];
    [self.scrollView addSubview:self.headerView];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _toolbar.frame = CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, 49);
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.top.equalTo(_toolbar.mas_bottom);
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
-(void)reloadData:(DeviceBean *) device{
    if (!self.isViewLoaded || !self.view.window){
        return;
    }
    __weak typeof(self) SELF = self;
    UIView *emptyView = [self.view viewWithTag:1001];
    self.toolbar.device = device;
    if(device){
        emptyView.hidden = YES;
        //获取发现页面数据
        [Loading show:nil];
        [[IFLYOSSDK shareInstance] getMusicGroups:device.device_id statusCode:^(NSInteger statusCode) {
            [Loading dismiss];
            SELF.NEED_REFRESH_UI = NO;
            if(statusCode != 200){
                [SELF loadDataEccur];
                SELF.NEED_REFRESH_UI = YES;
                [UIViewHelper showAlert:@"加载数据失败！" target:SELF callBack:^{
                    [SELF reloadData:APPDELEGATE.curDevice];
                } positiveTxt:@"重试" negativeTxt:@"取消"];
            }
            [SELF.headerView hw_endRefreshState];
        } requestSuccess:^(id _Nonnull data) {
            FindBean *findBean = [FindBean yy_modelWithJSON:data];
            if(findBean){
                [SELF loadDataSucess:findBean];
            }else{
                [SELF loadDataEccur];
            }
        } requestFail:^(id _Nonnull data) {}];
    }else{
        [self.view bringSubviewToFront:emptyView];
        emptyView.hidden = NO;
        [self loadDataEccur];
    }
}

//加载数据遇到错误
-(void)loadDataEccur{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.findBean = nil;
}

//加载数据成功
-(void)loadDataSucess:(FindBean*)bean{
    //清空容器
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.findBean = bean;
    //刷新Banner数据
    [self.collectionView reloadData];
    [self.scrollView addSubview:self.collectionView];
    [self.scrollView addSubview:self.pageCtrl];
    //对collectionView进行约束
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(APAGE_SIZE.width);
        make.height.mas_equalTo(APAGE_SIZE.height);
        make.centerX.mas_equalTo(self.view);
        //IOS 11.4不设置会出现布局紊乱
        make.top.mas_equalTo(0);
    }];
    self.pageCtrl.numberOfPages = self.findBean ? self.findBean.banners.count : 0;
    self.pageCtrl.currentPage = 0;
    [self.pageCtrl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.collectionView);
        make.height.mas_equalTo(50);
        make.centerX.mas_equalTo(self.view);
        make.bottom.equalTo(self.collectionView).offset(10);
    }];

    //是否显示购买音乐控件
    CGFloat offsetY = 0;
    if(!APPDELEGATE.curDevice.music.enable){
        //是否添加音乐支付入口
        [self addPayHeader: APPDELEGATE.curDevice.music];
        offsetY += (PAYVIEW_HEIGHT + VIEW_GAP);
        //对collectionView进行重约束
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(offsetY);
        }];
    }
    //添加指示器
    NSArray *temp = [bean.groups valueForKey:@"abbr"];
    NSMutableArray *array = NSMutableArray.new;
    for(NSString *abbr in temp){
        if(![array containsObject:abbr]){
            [array addObject:abbr];
        }
    }

    //添加动态音乐集
    self.verticalLayout = UIStackView.new;
    self.verticalLayout.axis = UILayoutConstraintAxisVertical;
    [self.scrollView addSubview:self.verticalLayout];
    
//    abbrs = [abbrs valueForKeyPath:@"@distinctUnionOfObjects.self"];
    [self addIndicator: array];
    
    //设置group视图约束
    CGFloat height = 0;
    for(GroupBean* gourpBean in _findBean.groups){
        GroupView *groupView = [GroupView newView];
        groupView.delegate = self;
        groupView.groupBean = gourpBean;
        [self.verticalLayout addArrangedSubview:groupView];
        height += groupView.uiHeight;
    }
    

    //设置垂直布局约束
    [self.verticalLayout mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(40 + 10);
        make.height.mas_equalTo(height);
    }];

    //设置scrollview的滚动区域
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH,
                                             offsetY  + APAGE_SIZE.height + CATEGORYVIEW_HEIGHT + height);
    self.scrollView.contentOffset = CGPointZero;
}

//添加开通音乐点击控件
-(void)addPayHeader:(MusicBean*) music{
    UIView *musicPayView = [[[NSBundle mainBundle] loadNibNamed:@"MusicPayView" owner:nil options:nil] lastObject];
    [self.scrollView addSubview:musicPayView];
    musicPayView.frame = CGRectMake(SCREEN_WIDTH * 0.15, 0, SCREEN_WIDTH * 0.7, PAYVIEW_HEIGHT);
    UILabel *label = [musicPayView.subviews objectAtIndex:1];
    label.text = music.text;
    [UIViewHelper attachClick:musicPayView target:self action:@selector(onPayClick)];
//    [musicPayView.subviews objectAtIndex:0].transform = CGAffineTransformMakeRotation(M_PI);
}

-(void)onPayClick{
    WebPageViewController *nvc = [WebPageViewController createNewPageWithUrl:APPDELEGATE.curDevice.music.redirect_url];
    [self.navigationController pushViewController:nvc animated:YES];
}

//添加指示器
-(void) addIndicator:(NSArray<NSString*>*) abbr{
    self.categoryView.titles = abbr;
    [self.scrollView addSubview:self.categoryView];
    [self.categoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(CATEGORYVIEW_HEIGHT);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark --UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([scrollView isKindOfClass:UICollectionView.class]){
        return;
    }
    CGFloat topY = (APPDELEGATE.curDevice.music.enable ? 0 : PAYVIEW_HEIGHT + VIEW_GAP);
    [self.categoryView mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat referY = APAGE_SIZE.height  + topY;
        CGFloat offsetY  = scrollView.contentOffset.y < referY ?  0 : scrollView.contentOffset.y - referY;
        make.top.equalTo(self.collectionView.mas_bottom).offset(offsetY);
    }];
    if(self.scrollView.contentOffset.y >= self.scrollView.contentSize.height - self.scrollView.frame.size.height){
        if(self.categoryView.selectedIndex != self.categoryView.titles.count - 1){
            [self.categoryView selectItemAtIndex:self.categoryView.titles.count - 1];
        }
    }else{
        CGFloat offsetY = self.scrollView.contentOffset.y - APAGE_SIZE.height + topY;
        NSInteger index = 0;
        for(GroupView *gView in self.verticalLayout.subviews){
            if(gView.frame.origin.y >  offsetY)
                break;
            index  = [self.categoryView.titles indexOfObject:gView.groupBean.abbr];
        }
        if(self.categoryView.selectedIndex != index){
            [self.categoryView selectItemAtIndex:index];
        }
    }
    [self.verticalLayout.subviews makeObjectsPerformSelector:@selector(checkToLoad)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if([scrollView isKindOfClass:UICollectionView.class]){
        BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (scrollToScrollStop) {
            int page = floor(scrollView.contentOffset.x / (APAGE_SIZE.width + 30));
            if(self.pageCtrl){
                self.pageCtrl.currentPage = page;
            }
        }
        return;
    }
}


#pragma mark --UICollectionViewDelegate
-( void )collectionView:( UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    BannerBean *bannerBean = _findBean.banners[indexPath.row];
    WebPageViewController *newPage = [WebPageViewController createNewPageWithUrl:bannerBean.url];
    newPage.isInterupt = true;
    [self.navigationController pushViewController:newPage animated:YES];
}

#pragma mark --UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.findBean ? self.findBean.banners.count : 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    UIImageView *imageView = [cell.subviews objectAtIndex:0];
   [imageView sd_setImageWithURL:[NSURL URLWithString:_findBean.banners[index].image]];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return APAGE_SIZE;
}

#pragma mark --JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index{
    NSString *title = self.categoryView.titles[index];
    for(GroupView *gView in self.verticalLayout.subviews){
        if([gView.groupBean.abbr isEqualToString:title]){
            CGFloat topY = (APPDELEGATE.curDevice.music.enable ? 0 : PAYVIEW_HEIGHT + VIEW_GAP);
            CGFloat referY = gView.frame.origin.y + APAGE_SIZE.height  + topY;
            referY = MIN(referY, self.scrollView.contentSize.height - self.scrollView.frame.size.height);
            [self.scrollView setContentOffset:CGPointMake(0,referY) animated:YES];
            break;
        }
    }
}

#pragma mark --ISelectedDelegate
- (void)groupView:(GroupView *)groupView canClickItemAtIndex:(ItemBean *)bean{
    ItemViewController *ivc =  [ItemViewController createNewPage:bean];
    //test
//    MusicPlayViewController *mvc = [[MusicPlayViewController alloc] initWithNibName:@"MusicPlayViewController" bundle:nil];
    [self.navigationController pushViewController:ivc animated:YES];
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
        self.lineLayout = [PageLineLayout new];
        self.lineLayout.itemSize = APAGE_SIZE;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.lineLayout];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        [_collectionView registerNib:[UINib nibWithNibName:@"FindBannerCell" bundle:nil] forCellWithReuseIdentifier:ID];
    }
    return _collectionView;
}

#pragma mark --categoryView懒加载
-(JXCategoryTitleView*) categoryView{
    if(!_categoryView){
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectZero];
        _categoryView.titleColor = [UIColor lightGrayColor];
        _categoryView.titleSelectedColor = [UIColor blackColor];
        _categoryView.delegate = self;
        _categoryView.backgroundColor = _toolbar.backgroundColor;
        self.categoryView.titleColorGradientEnabled = YES;
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorHeight = 3;
        lineView.indicatorColor = [UIColor colorWithHexString:@"#f6921e"];
        lineView.indicatorWidth = 20;
        self.categoryView.indicators = @[lineView];
    }
    return _categoryView;
}

#pragma mark --HWHeadRefresh懒加载
-(HWHeadRefresh*) headerView{
    if(!_headerView){
        _headerView = HWHeadRefresh.new;
        [_headerView hw_addFooterRefreshWithView:_scrollView hw_footerRefreshBlock:^{
            [self reloadData:APPDELEGATE.curDevice];
        }];
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

@end
