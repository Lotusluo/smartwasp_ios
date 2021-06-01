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

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define APAGE_SIZE (CGSizeMake(SCREEN_WIDTH - 30,SCREEN_WIDTH * 0.27))
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define OFFSET_HEIGHT 40
#define FLOAT (OFFSET_HEIGHT + APAGE_SIZE.height)

@interface FinderViewController ()<UIScrollViewDelegate,UICollectionViewDataSource>
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

@end

@implementation FinderViewController

static NSString *const ID = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initToolbar];
    [self initScrollview];
    //对选择的设备进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devSetObserver:)
                                                 name:@"devSetNotification"
                                               object:nil];
    [self devSetObserver:nil];
    // Do any additional setup after loading the view from its nib.
}

//初始化自定义导航条
-(void) initToolbar{
    _toolbar = [Toolbar newView];
    [self.view addSubview:_toolbar];
}

-(void) initScrollview{
    HWHeadRefresh *headrefresh = HWHeadRefresh.new;
    _scrollView.delegate = self;
    [_scrollView addSubview:headrefresh];
    [headrefresh hw_addFooterRefreshWithView:_scrollView hw_footerRefreshBlock:^{
        
    }];
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
    
    //test
    APPDELEGATE.curDevice.music.enable = FALSE;
    APPDELEGATE.curDevice.music.text = @"请开通音乐权限!";

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
    if(!APPDELEGATE.curDevice.music.enable){
        //是否添加音乐支付入口
        [self addPayHeader: APPDELEGATE.curDevice.music];
        //对collectionView进行重约束
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(OFFSET_HEIGHT);
        }];
    }
    //添加指示器
    NSArray *abbrs = [bean.groups valueForKey:@"abbr"];
    abbrs = [abbrs valueForKeyPath:@"@distinctUnionOfObjects.self"];
    [self addIndicator:abbrs];
}

//添加开通音乐点击控件
-(void) addPayHeader:(Music*) music{
    UIView *musicPayView = [[[NSBundle mainBundle] loadNibNamed:@"MusicPayView" owner:nil options:nil] lastObject];
    [_container addSubview:musicPayView];
    [musicPayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(30);
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
        make.top.equalTo(self.collectionView.mas_bottom).offset(10);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(30);
        make.centerX.equalTo(self.container);
    }];
}

//加载数据遇到错误
-(void)loadDataEccur{
    NSLog(@"loadDataEccur");
}

#pragma mark --UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.categoryView mas_updateConstraints:^(MASConstraintMaker *make) {
        float offsetY  = scrollView.contentOffset.y < FLOAT ?  0 : scrollView.contentOffset.y - FLOAT;
        make.top.equalTo(self.collectionView.mas_bottom).offset(offsetY + 10);
    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -collectionView懒加载
-(UICollectionView*) collectionView{
    if(!_collectionView){
        self.lineLayout = [PageLineLayout new];
        self.lineLayout.itemSize = APAGE_SIZE;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.lineLayout];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"FindBannerCell" bundle:nil] forCellWithReuseIdentifier:ID];
    }
    return _collectionView;
}

#pragma mark -categoryView懒加载
-(JXCategoryTitleView*) categoryView{
    if(!_categoryView){
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectZero];
        _categoryView.titleColor = [UIColor lightGrayColor];
        _categoryView.titleSelectedColor = [UIColor blackColor];
        self.categoryView.titleColorGradientEnabled = YES;
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorHeight = 1;
        lineView.indicatorColor = [UIColor colorWithHexString:@"#f6921e"];
        lineView.indicatorWidth = 20;
        self.categoryView.indicators = @[lineView];
    }
    return _categoryView;
}

@end
