//
//  ItemViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/10.
//

#import "ItemViewController.h"
#import "NormalToolbar.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"
#import "AppDelegate.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import "NSObject+YYModel.h"
#import "SongsBean.h"
#import "HWFooterRefresh.h"
#import <Masonry.h>

@interface ItemViewController ()<
UITableViewDataSource,
UITableViewDelegate>

/**########################引用的控件########################*/
@property (weak, nonatomic) IBOutlet NormalToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIImageView *blurImage;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UILabel *fromView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listHeight;
//数据
@property (strong,nonatomic) ItemBean *bean;
//音乐数据
@property (strong,nonatomic) NSMutableArray *songsData;
//数据列表控件
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//临界值
@property (nonatomic) CGFloat zeroValue;
//刷新控件
@property (nonatomic,strong) HWFooterRefresh *footerView;

@end

@implementation ItemViewController

static NSString *const ID = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolBar.title = @"歌单";
    self.songsData = NSMutableArray.new;
    [self attchUI];
    if (@available(iOS 11.0, *)) {
        if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    // Do any additional setup after loading the view from its nib.
}

-(void) attchUI{
    self.nameView.text = self.bean.name;
    self.fromView.text =  self.bean.from;
    self.blurImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.blurImage sd_setImageWithURL:[NSURL URLWithString:self.bean.image] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(image){
            __weak typeof(self) _self = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *blur = [UIImage imageBlurImage:image WithBlurNumber:0.5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _self.blurImage.image = blur;
                });
            });
        }
    }];
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:self.bean.image]];
    [self.tableView addSubview:self.footerView];
}

-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.iconTop.constant = sgm_safeAreaInset(self.view).top + 49;
    self.headerHeight.constant = self.iconTop.constant + self.iconView.frame.size.height + 20;
    self.zeroValue = self.headerHeight.constant - self.iconTop.constant;
    self.listHeight.constant = self.scrollView.frame.size.height - (self.headerHeight.constant - self.zeroValue);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refresh];
}

+(ItemViewController *) createNewPage:(ItemBean *) bean{
    ItemViewController *vc = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
    vc.bean = bean;
    return vc;
}

//播放全部
- (IBAction)onPlayClick:(id)sender {
    
}

//刷新数据
-(void)refresh{
    __weak typeof(self) _self = self;
    [[IFLYOSSDK shareInstance] getMusicGroupsList:1 limit:20 groupId:self.bean._id statusCode:^(NSInteger statusCode) {
        if(statusCode != 200){
            NSLog(@"刷新失败!");
        }
    } requestSuccess:^(id _Nonnull data) {
        SongsBean *songsBean = [SongsBean yy_modelWithJSON:data];
        [_self.songsData removeAllObjects];
        [_self.songsData addObjectsFromArray:songsBean.items];
        [_self.tableView reloadData];
    } requestFail:^(id _Nonnull data) {
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

#pragma mark --UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    SongBean *song=[self.songsData objectAtIndex:indexPath.row];
    cell.textLabel.text = song.name;
    cell.detailTextLabel.text = song.artist;
    return cell;
}

#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _scrollView) {
        if (_tableView.contentOffset.y > 0) {
            // header已经消失，开始滚动下面的_table，并让_scroll不动
            _scrollView.contentOffset = CGPointMake(0, _zeroValue);
        }
        if (_scrollView.contentOffset.y < _zeroValue) {
            // header已经显示出来，重置_table.contentOffset为0
            _tableView.contentOffset = CGPointZero;
            CGFloat _alpha = 1 - fabs(_scrollView.contentOffset.y)/ _zeroValue;
            if(_scrollView.contentOffset.y < 0){
                _alpha = 1;
            }
            _iconView.alpha = _alpha;
            _fromView.alpha = _iconView.alpha;
            _nameView.alpha = _iconView.alpha;
        }else{
            _iconView.alpha = 0;
            _fromView.alpha = _iconView.alpha;
            _nameView.alpha = _iconView.alpha;
        }
    }
    else if (scrollView == _tableView) {
        if (_scrollView.contentOffset.y < _zeroValue) {
            // header还没有消失，那么_table.contentOffset一直为0
            _tableView.contentOffset = CGPointZero;
            _tableView.showsVerticalScrollIndicator = NO;
        }
        else {
            // header已经消失
            _scrollView.contentOffset = CGPointMake(0, _zeroValue);
            _tableView.showsVerticalScrollIndicator = YES;
        }
    }
}


#pragma mark --HWFooterRefresh懒加载
-(HWFooterRefresh*) footerView{
    if(!_footerView){
        _footerView = HWFooterRefresh.new;
        [_footerView hw_addFooterRefreshWithView:self.tableView hw_footerRefreshBlock:^{
            
        }];
    }
    return _footerView;
}


@end


@implementation EGOScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end
