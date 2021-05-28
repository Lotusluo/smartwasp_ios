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
#import <Masonry.h>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define APAGE_SIZE (CGSizeMake(SCREEN_WIDTH - 30,SCREEN_WIDTH * 0.27))
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface UserViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>


//自定义toolbar
@property (weak, nonatomic) IBOutlet UIView *toolbar;
//左侧按钮
@property (weak, nonatomic) IBOutlet UIImageView *leftItem;
//设备选择banner
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//collectionView布局
@property (weak, nonatomic) IBOutlet PageLineLayout *lineLayout;
//指示器
@property (weak, nonatomic) IBOutlet PageControl2 *pageControl;
//用户操作navi按钮
@property (weak, nonatomic) IBOutlet UIScrollView *menuList;

@end

@implementation UserViewController

@synthesize toolbar;
@synthesize collectionView;
@synthesize pageControl;
@synthesize lineLayout;
@synthesize menuList;

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
    lineLayout.itemSize = APAGE_SIZE;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerNib:[UINib nibWithNibName:@"DeviceBannerCell" bundle:nil] forCellWithReuseIdentifier:ID];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.width.mas_equalTo(APAGE_SIZE.width);
           make.height.mas_equalTo(APAGE_SIZE.height);
           make.top.equalTo(toolbar.mas_bottom);
       }];
}

//初始化page ctl
-(void)initpageCtr{
    pageControl.pageIndicatorTintColor =  [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#f6921e"];
    pageControl.enabled = false;
}

//初始化menulist
-(void)initMenuList{
    //设置内容区域
    menuList.contentSize = CGSizeMake(SCREEN_WIDTH, 1000);
    
}

-(void)reloadData{
    pageControl.numberOfPages = APPDELEGATE.devices ? APPDELEGATE.devices.count + 1 : 1;
    pageControl.tag = 0;
    [collectionView reloadData];
    [self setCurrentPage:0];
}

#pragma mark --UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return pageControl.numberOfPages;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DeviceBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    NSInteger index = indexPath.row - 1;
    if(index == -1){
        Device *header = [[Device alloc] init];
        header.alias = @"header";
        [cell render:header];
    }else{
        [cell render:[APPDELEGATE.devices objectAtIndex:index]];
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
    [pageControl setCurrentPage:page];
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
