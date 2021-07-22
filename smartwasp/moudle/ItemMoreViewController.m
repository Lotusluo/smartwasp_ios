//
//  ItemMoreViewController.m
//  smartwasp
//
//  Created by luotao on 2021/7/21.
//

#import "ItemMoreViewController.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import <Masonry.h>
#import "ListViewController.h"
#import "LXSEQView.h"
#import "UIViewHelper.h"
#import "MusicPlayViewController.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface ItemMoreViewController ()<JXCategoryViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet LXSEQView *musicView;

@end

@implementation ItemMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customRightItem];
    self.map = NSMutableDictionary.new;
    [self setupCategoryView];
    [self setupAbbr];
    self.title = self.groupBean.name;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}


//自定义右侧导航按钮
-(void)customRightItem{
    [UIViewHelper attachClick:self.musicView target:self action:@selector(doTapMethod)];
    UIBarButtonItem * jumpItem = [[UIBarButtonItem alloc] initWithCustomView:self.musicView];
    self.navigationItem.rightBarButtonItem = jumpItem;
}

//音乐控件点击
-(void)doTapMethod{
    MusicPlayViewController *mvc = MusicPlayViewController.new;
    [self.navigationController pushViewController:mvc animated:YES];
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

/**
 添加指示器
 */
-(void)setupAbbr{
    NSArray *temp = [self.items valueForKeyPath:@"category_name"];
    temp = [temp valueForKeyPath:@"@distinctUnionOfObjects.self"];
    self.categoryView.titles = temp;
    for(NSString* key in temp){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.category_name contains[c] %@",key];
        NSArray *values = [self.items filteredArrayUsingPredicate:predicate];
        self.map[key] = values;
    }
}

//设置类别控件
-(void)setupCategoryView{
    self.categoryView.titleColor = [UIColor lightGrayColor];
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.delegate = self;
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorHeight = 3;
    lineView.indicatorColor = [UIColor colorWithHexString:@"#f6921e"];
    lineView.indicatorWidth = 20;
    self.categoryView.indicators = @[lineView];
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.top.mas_equalTo(self.categoryView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    self.categoryView.listContainer = self.listContainerView;
    UIScrollView *scrollView = self.listContainerView.scrollView;
    [scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
//    NSArray *gestureArray = self.navigationController.view.gestureRecognizers;
//       for (UIGestureRecognizer *gesture in gestureArray) {
//           if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
//               [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:gesture];
//           }
//       }


}

//列表容器视图
- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    return _listContainerView;
}

#pragma mark - JXCategoryListContainerViewDelegate
// 返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}

// 返回各个列表菜单下的实例，该实例需要遵守并实现 <JXCategoryListContentViewDelegate> 协议
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    ListViewController *list = [[ListViewController alloc] init];
    list.lists = self.map[self.categoryView.titles[index]];
    return list;
}

#pragma mark - JXCategoryViewDelegate
// 点击选中或者滚动选中都会调用该方法。适用于只关心选中事件，不关心具体是点击还是滚动选中的。
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didScrollSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

//静态构造
+(ItemMoreViewController *) createNewPage:(NSArray<ItemBean*> *) items group:(GroupBean *) groupBean{
    ItemMoreViewController *vc = [[ItemMoreViewController alloc] initWithNibName:@"ItemMoreViewController" bundle:nil];
    vc.groupBean = groupBean;
    vc.items = items;
    return vc;
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
