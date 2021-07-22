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
#import "MusicItemCell.h"
#import "Loading.h"
#import "LXSEQView.h"
#import "iToast.h"
#import "MusicPlayViewController.h"
#import "UIViewHelper.h"
#import "IFlyOSBean.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define ONE_PAGE 10

@interface ItemViewController ()<
UITableViewDataSource,
UITableViewDelegate>

/**########################引用的控件########################*/
@property (weak, nonatomic) IBOutlet UIImageView *blurImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jumpTop;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UILabel *fromView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listHeight;
@property (weak, nonatomic) IBOutlet LXSEQView *musicView;
//数据
@property (strong,nonatomic) ItemBean *bean;
//音乐数据
@property (strong,nonatomic) NSMutableArray *songsData;
//数据列表控件
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//临界值
@property (nonatomic) CGFloat zeroValue;
//数据是否在请求中
@property (nonatomic) BOOL isRequest;
//刷新控件
@property (nonatomic,strong) HWFooterRefresh *footerView;

@end

@implementation ItemViewController

static NSString *const ID = @"MusicItemCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.title = @"歌单";
    self.songsData = NSMutableArray.new;
    [self customRightItem];
    if (@available(iOS 11.0, *)) {
        if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    [self attachUI];
    // Do any additional setup after loading the view from its nib.
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

-(void)attachUI{
    self.nameView.text = self.bean.name;
    self.bean.from = [self.bean.from stringByReplacingOccurrencesOfString:@"内容来源" withString:@"版权所有"];
    self.fromView.text =  self.bean.from;
//    if(self.bean.from && [self.bean.from rangeOfString:@"内容来源" options:NSRegularExpressionSearch].location != NSNotFound){
//
//    }
    self.blurImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.blurImage sd_setImageWithURL:[NSURL URLWithString:self.bean.image]];
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:self.bean.image] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(image){
            __weak typeof(self) _self = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *blur = [UIImage imageBlurImage:image WithBlurNumber:0.5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"blurImage:%@",_self.blurImage);
                    _self.blurImage.image = blur;
                });
            });
        }
    }];
    [self.tableView addSubview:self.footerView];
    [self.tableView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellReuseIdentifier:ID];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.iconTop.constant = sgm_safeAreaInset(self.view).top;
    self.headerHeight.constant = self.iconTop.constant + self.iconView.frame.size.height + 20;
    self.zeroValue = self.headerHeight.constant - self.iconTop.constant;
    self.listHeight.constant = self.scrollView.frame.size.height - (self.headerHeight.constant - self.zeroValue + 26);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.NEED_REFRESH_UI){
        [self refresh];
    }
}

//处理设备媒体状态通知
-(void)mediaSetCallback:(MusicStateBean* __nullable) musicStateBean{
    if (self.isViewLoaded && self.view.window){
//#pragma GCC diagnostic ignored "-Wundeclared-selector"
//#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.tableView.visibleCells makeObjectsPerformSelector:@selector(updatePlayStatus:) withObject:musicStateBean];
#pragma clang diagnostic pop
        if(musicStateBean && musicStateBean.isPlaying){
            [self.musicView startAnimation];
            return;
        }
    }
    [self.musicView stopAnimation];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:nil];
}

+(ItemViewController *) createNewPage:(ItemBean *) bean{
    ItemViewController *vc = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
    vc.bean = bean;
    return vc;
}

//刷新数据
-(void)refresh{
    [Loading show:nil];
    [self.songsData removeAllObjects];
    [self request:1 limit:2 * ONE_PAGE];
    self.NEED_REFRESH_UI = NO;
}

#pragma mark --HWFooterRefresh懒加载
-(HWFooterRefresh*) footerView{
    if(!_footerView){
        _footerView = HWFooterRefresh.new;
        __weak typeof(self) _self = self;
        [_footerView hw_addFooterRefreshWithView:self.tableView hw_footerRefreshBlock:^{
            NSInteger count = _self.songsData.count;
            if((count % ONE_PAGE) > 0){
                [_self.footerView hw_toNoMoreState:YES];
                return;
            }
            NSInteger requestPage = count / ONE_PAGE + 1;
            [_self request:requestPage limit:ONE_PAGE];
        }];
    }
    return _footerView;
}

//分页请求
-(void)request:(NSInteger)page limit:(NSInteger)limit{
    if(self.isRequest)
        return;
    __weak typeof(self) _self = self;
    self.isRequest = YES;
    [[IFLYOSSDK shareInstance] getMusicGroupsList:page limit:limit groupId:self.bean._id statusCode:^(NSInteger statusCode) {
        self.isRequest = NO;
        [Loading dismiss];
        if(statusCode != 200){
            NSLog(@"请求失败");
        }
    } requestSuccess:^(id _Nonnull data) {
        SongsBean *songsBean = [SongsBean yy_modelWithJSON:data];
        [_self.songsData addObjectsFromArray:songsBean.items];
        [_self.tableView reloadData];
        [_self.footerView hw_toNoMoreState:songsBean.items.count  < limit];
    } requestFail:^(id _Nonnull data) {
        NSLog(@"请求失败");
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
    MusicItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    SongBean *song=[self.songsData objectAtIndex:indexPath.row];
    cell.song = song;
    cell.serial = indexPath.row + 1;
    cell.groupID = self.bean._id;
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进行播放
    [Loading show:nil];
    SongBean *song=[self.songsData objectAtIndex:indexPath.row];
    [[IFLYOSSDK shareInstance] musicControlPlayGroup:APPDELEGATE.curDevice.device_id groupId:self.bean._id mediaId:song._id statusCode:^(NSInteger code) {
        [Loading dismiss];
    } requestSuccess:^(id _Nonnull data) {
        [[iToast makeText:[NSString stringWithFormat:NSLocalizedString(@"play_now", nil),song.name]] show];
    } requestFail:^(id _Nonnull data) {
        if([NSStringFromClass([data class]) containsString:@"_NSInlineData"]){
            NSString * errMsg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            IFlyOSBean *osBean = [IFlyOSBean yy_modelWithJSON:errMsg];
            [[iToast makeText:osBean.message] show];
        }else{
            [[iToast makeText:NSLocalizedString(@"load_music_err", nil)] show];
        }
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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

- (IBAction)onPlayAll:(id)sender {
    [Loading show:nil];
    [[IFLYOSSDK shareInstance] musicControlPlayGroup:APPDELEGATE.curDevice.device_id groupId:self.bean._id mediaId:@"" statusCode:^(NSInteger code) {
        [Loading dismiss];
    } requestSuccess:^(id _Nonnull data) {
        [[iToast makeText:NSLocalizedString(@"play_now1", nil)] show];
    } requestFail:^(id _Nonnull data) {
        if([NSStringFromClass([data class]) containsString:@"_NSInlineData"]){
            NSString * errMsg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            IFlyOSBean *osBean = [IFlyOSBean yy_modelWithJSON:errMsg];
            [[iToast makeText:osBean.message] show];
        }else{
            [[iToast makeText:NSLocalizedString(@"load_music_err", nil)] show];
        }
    }];
}


@end


@implementation EGOScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end
