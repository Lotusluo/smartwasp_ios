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
#import <Masonry.h>

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
@property (weak, nonatomic) IBOutlet UIView *toolbar;
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

@end

@implementation UserViewController

static NSString *const ID = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initGallery];
    [self initpageCtr];
    [self initMenuList];
    [self reloadData];
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

//初始化page ctl
-(void)initpageCtr{
    self.pageControl.pageIndicatorTintColor =  [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#f6921e"];
    self.pageControl.enabled = false;
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
-(void) onClick:(NSInteger)tag{
    NSLog(@"onClick:%ld",tag);
}

//重加载数据
-(void)reloadData{
    self.pageControl.numberOfPages = APPDELEGATE.devices ? APPDELEGATE.devices.count + 1 : 1;
    self.pageControl.tag = 0;
    [self.collectionView reloadData];
    [self setCurrentPage:0];
}

#pragma mark --UICollectionViewDelegate
-( void )collectionView:( UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    if(indexPath.row){
        //点击进入设备详情界面
        DeviceBean *selctedBean = APPDELEGATE.devices[indexPath.row - 1];
        DeviceSetViewController *dvc = [DeviceSetViewController createNewPage:selctedBean];
        [self.navigationController pushViewController:dvc animated:YES];
        return;
    }
    //进入添加设备界面
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
