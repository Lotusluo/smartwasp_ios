//
//  FinderViewController.m
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import "FinderViewController.h"
#import "AppDelegate.h"
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
#import "NewPageViewController.h"
#import "ItemViewController.h"
#import "MusicPlayViewController.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//控件容器
@property (weak, nonatomic) IBOutlet UIView *container;
//控制容器高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeight;
//Banner图
@property (strong, nonatomic)  UICollectionView *collectionView;
@property (strong, nonatomic)  PageLineLayout *lineLayout;
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
    [self.view addSubview:_toolbar];
    //添加刷新控件
    [self.scrollView addSubview:self.headerView];
    self.scrollView.delegate = self;
    //对选择的设备进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devSetObserver:)
                                                 name:@"devSetNotification"
                                               object:nil];
    [self devSetObserver:nil];
    // Do any additional setup after loading the view from its nib.
}

//即将被布局
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //布局前重置一下toolbar的frame
    _toolbar.frame = CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, 49);

}

#pragma mark - 处理通知
-(void)devSetObserver:(NSNotification*)notification {
    NSLog(@"收到设备选择的消息通知");
    if(APPDELEGATE.curDevice){
        [self.toolbar setDevName:APPDELEGATE.curDevice.alias];
        [self.toolbar setDevStatus:APPDELEGATE.curDevice.isOnLine];
        [self reloadData];
    }else{
        [self.toolbar setEmpty];
    }
}

//重加载数据
-(void)reloadData{
    //获取发现页面数据
    if(APPDELEGATE.curDevice){
        [[IFLYOSSDK shareInstance] getMusicGroups:APPDELEGATE.curDevice.device_id statusCode:^(NSInteger statusCode) {
            if(statusCode != 200){
                [self loadDataEccur];
            }
            NSLog(@"状态码：%li",statusCode);
        } requestSuccess:^(id _Nonnull data) {
            FindBean *findBean = [FindBean yy_modelWithJSON:data];
            if(findBean){
                [self loadDataSucess:findBean];
            }else{
                [self loadDataEccur];
            }
        } requestFail:^(id _Nonnull data) {
            [self loadDataEccur];
        }];
    }else{
        //暂无设备
    }
}

//加载数据成功
-(void)loadDataSucess:(FindBean*)bean{
    //清空容器
    [self.container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.findBean = bean;
    
    //刷新Banner数据
    [self.collectionView reloadData];
    [self.container addSubview:self.collectionView];
    //对collectionView进行约束
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(APAGE_SIZE.width);
        make.height.mas_equalTo(APAGE_SIZE.height);
        make.centerX.mas_equalTo(self.container);
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
//    abbrs = [abbrs valueForKeyPath:@"@distinctUnionOfObjects.self"];
    [self addIndicator: array];
    
    //添加动态音乐集
    self.verticalLayout = UIStackView.new;
    self.verticalLayout.axis = UILayoutConstraintAxisVertical;
    [self.container addSubview:self.verticalLayout];
    
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
    [self.verticalLayout mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(40 + 10);
        make.height.mas_equalTo(height);
    }];
    
    //设置scrollview的滚动区域
    _containerHeight.constant = offsetY  + APAGE_SIZE.height + CATEGORYVIEW_HEIGHT +height ;
}

//添加开通音乐点击控件
-(void) addPayHeader:(MusicBean*) music{
    UIView *musicPayView = [[[NSBundle mainBundle] loadNibNamed:@"MusicPayView" owner:nil options:nil] lastObject];
    [_container addSubview:musicPayView];
    [musicPayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.7);
        make.height.mas_equalTo(PAYVIEW_HEIGHT);
        make.centerX.equalTo(self.container);
    }];
    UILabel *label = [musicPayView.subviews objectAtIndex:1];
    label.text = music.text;
    [musicPayView.subviews objectAtIndex:0].transform = CGAffineTransformMakeRotation(M_PI);
}

//添加指示器
-(void) addIndicator:(NSArray<NSString*>*) abbr{
    self.categoryView.titles = abbr;
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(CATEGORYVIEW_HEIGHT);
        make.centerX.equalTo(self.container);
    }];
}

//加载数据遇到错误
-(void)loadDataEccur{
    NSLog(@"loadDataEccur");
}

#pragma mark --UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([scrollView isKindOfClass:UICollectionView.class])
        return;
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
}


#pragma mark --UICollectionViewDelegate
-( void )collectionView:( UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    BannerBean *bannerBean = _findBean.banners[indexPath.row];
    NewPageViewController *newPage = [NewPageViewController createNewPageWithUrl:bannerBean.url];
    newPage.isInterupt = true;
    [self.navigationController pushViewController:newPage animated:YES];
    NSLog(@"%@",bannerBean.url);
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
            dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, 3* NSEC_PER_SEC);
            dispatch_after(time_t, dispatch_get_main_queue(), ^{
                [self->_headerView hw_endRefreshState];
            });
        }];
    }
    return _headerView;
}

@end
