//
//  UserViewController.m
//  smartwasp
//
//  Created by luotao on 2021/4/9.
//

#import "UserViewController.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "AppDelegate.h"
#import "DeviceBannerCell.h"
#import "PageLineLayout.h"
#import "PageControl2.h"
#import "NormalNaviCell.h"
#import "DeviceSetViewController.h"
#import "WebPageViewController.h"
#import <Masonry.h>
#import "IFLYOSSDK.h"
#import "LXSEQView.h"
#import "UsrCenterViewController.h"
#import "AddDeviceViewController.h"
#import "iToast.h"
#import "UIViewHelper.h"
#import "MusicPlayViewController.h"
#import "AboutViewController.h"
#import "Loading.h"
#import "UIView+Extension.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define APAGE_SIZE (CGSizeMake(SCREEN_WIDTH - 30,SCREEN_WIDTH * 0.27))
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface UserViewController ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
ISWClickDelegate>


/**###############ToolBar###############*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeight;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet LXSEQView *musicView;
@property (weak, nonatomic) IBOutlet UIImageView *leftItem;

/**###############DeviceBanner###############*/
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet PageLineLayout *lineLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeight;

/**###############Indicator###############*/
@property (weak, nonatomic) IBOutlet PageControl2 *pageControl;

/**###############按钮视图###############*/
@property (weak, nonatomic) IBOutlet UIStackView *naviContent;

@property(nonatomic)BOOL test;

@end

@implementation UserViewController

static NSString *const ID = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initGallery];
    [self initpageCtr];
    [self initMenuList];
    self.toolBarHeight.constant = STATUS_HEIGHT;
    //对选择的设备进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devsSetObserver:)
                                                 name:@"devsSetNotification"
                                               object:nil];
    [UIViewHelper attachClick:self.musicView target:self action:@selector(doTapMethod)];
}

//音乐控件点击
-(void)doTapMethod{
    if(!APPDELEGATE.curDevice){
        [[iToast makeText:@"暂无设备"] show];
        return;
    }
    MusicPlayViewController *mvc = MusicPlayViewController.new;
    [self.navigationController pushViewController:mvc animated:YES];
}

//初始化设备选择栏
-(void) initGallery{
    self.lineLayout.itemSize = APAGE_SIZE;
    self.bannerWidth.constant = APAGE_SIZE.width;
    self.bannerHeight.constant = APAGE_SIZE.height;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DeviceBannerCell" bundle:nil] forCellWithReuseIdentifier:ID];
}

//处理设备列表通知
-(void)devsSetObserver:(NSNotification*)notification {
    self.NEED_REFRESH_UI = YES;
    [self reloadData];
}

//处理设备媒体状态通知
-(void)mediaSetCallback:(MusicStateBean* __nullable) musicStateBean{
    if (self.isViewLoaded && self.view.window){
        if(musicStateBean && musicStateBean.isPlaying){
            [self.musicView startAnimation];
            return;
        }
    }
    [self.musicView stopAnimation];
}

//设备在线状态变更
-(void)onLineChangedCallback{
    [self.collectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.NEED_REFRESH_UI){
        [self reloadData];
    }
}

//初始化page ctl
-(void)initpageCtr{
    self.pageControl.pageIndicatorTintColor =  [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#f6921e"];
    self.pageControl.enabled = false;
    self.lineLayout.pageControl = self.pageControl;
}

//初始化menulist
-(void)initMenuList{
    //设置内容区域
     NSEnumerator *arrayEnumerator = [_naviContent.subviews objectEnumerator];
     UIView *obj;
     while ((obj = [arrayEnumerator nextObject]) != nil) {
         if([obj isKindOfClass:NormalNaviCell.class]){
             NormalNaviCell *nnView = (NormalNaviCell*)obj;
             nnView.delegate = self;
         }
    }
}

//菜单点击事件
-(void)onClick:(NSInteger)tag{
    if(tag == 4){
        AboutViewController *amv = AboutViewController.new;
        [self.navigationController pushViewController:amv animated:YES];
        return;
    }
    URL_PATH_ENUM path;
    if(tag == 1){
        path = IFTTT;
    }else if(tag == 2){
        path = CLOCKS;
    }else {
        path = ACCOUNTS;
    }
    WebPageViewController *nvc = [WebPageViewController createNewPageWithPath:path];
    [self.navigationController pushViewController:nvc animated:YES];
}

//重加载数据
-(void)reloadData{
    if (!self.isViewLoaded || !self.view.window){
        return;
    }
    self.pageControl.numberOfPages = APPDELEGATE.devices ? APPDELEGATE.devices.count + 1 : 1;
    [self.collectionView reloadData];
    //判断当前的设备索引号
    if(APPDELEGATE.curDevice){
        NSInteger index = [APPDELEGATE.devices indexOfObject:APPDELEGATE.curDevice] + 1;
        [self setCurrentPage:index];
    }else{
        [self setCurrentPage:0];
    }
    self.NEED_REFRESH_UI = NO;
}

#pragma mark --UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row){
        //点击进入设备详情界面
        DeviceBean *selctedBean = APPDELEGATE.devices[indexPath.row - 1];
        DeviceSetViewController *dvc = [DeviceSetViewController createNewPage:selctedBean];
        [self.navigationController pushViewController:dvc animated:YES];
        return;
    }
    //进入添加设备界面
    AddDeviceViewController *avc = AddDeviceViewController.new;
    [self.navigationController pushViewController:avc animated:YES];
}

#pragma mark --UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.pageControl.numberOfPages;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DeviceBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    NSInteger index = indexPath.row - 1;
    if(index == -1){
        DeviceBean *header = [[DeviceBean alloc] init];
        header.alias = @"header";
        [cell render:header];
    }else{
        [cell render:APPDELEGATE.devices[index]];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return APAGE_SIZE;
}

#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        int page = floor(scrollView.contentOffset.x / (APAGE_SIZE.width + 30));
        [self setCurrentPage:page];
    }
}

-(void)setCurrentPage:(NSInteger) page{
    [self.pageControl setCurrentPage:page];
    CGFloat offsetX = floor(page * (APAGE_SIZE.width + 30));
    if(self.collectionView.contentOffset.x == offsetX)
        return;
    __weak typeof(self) SELF = self;
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, 0.2* NSEC_PER_SEC);
    dispatch_after(time_t, dispatch_get_main_queue(), ^{
        SELF.collectionView.contentOffset = CGPointMake(offsetX, 0);
        [SELF.pageControl setCurrentPage:page];
    });
}


- (IBAction)onUsrCenterClick:(id)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    UsrCenterViewController *ucvc = [board instantiateViewControllerWithIdentifier: @"UsrCenterViewController"];
    [self.navigationController pushViewController:ucvc animated:YES];
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
