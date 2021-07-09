//
//  SearchViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/30.
//

#import "SearchViewController.h"
#import "MusicItemCell.h"
#import "SearchBean.h"
#import "HWFooterRefresh.h"
#import <iflyosSDKForiOS/iflyosCommonSDK.h>
#import "AppDelegate.h"
#import "Loading.h"
#import "iToast.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define STATUS_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)


#define ONE_PAGE 10

@interface SearchViewController ()<
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate>

//搜索列表控件
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//音乐数据
@property (strong,nonatomic) NSMutableArray *songsData;
@property (strong,nonatomic)UISearchBar *searchBar;
//数据是否在请求中
@property (nonatomic) BOOL isRequest;
//刷新控件
@property (nonatomic,strong) HWFooterRefresh *footerView;
@property (nonatomic,copy)NSString *keyWords;

@end

@implementation SearchViewController

static NSString *const ID = @"MusicItemCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.songsData = NSMutableArray.new;
    [self.tableView addSubview:self.footerView];
    [self.tableView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellReuseIdentifier:ID];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.navigationItem.rightBarButtonItem = searchItem;
    // Do any additional setup after loading the view from its nib.
}

-(void)onCancelInput{
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
//    self.searchBar.text = self.keyWords;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

//刷新数据
-(void)search:(NSString*)kw{
    self.keyWords = kw;
    [Loading show:nil];
    [self.songsData removeAllObjects];
    if(self.keyWords && ![self.keyWords isEqualToString:@""]){
        [self request:1 limit:2 * ONE_PAGE];
    }
}

//分页请求
-(void)request:(NSInteger)page limit:(NSInteger)limit{
    if(self.isRequest)
        return;
    __weak typeof(self) _self = self;
    self.isRequest = YES;
    [[IFLYOSSDK shareInstance] searchMusic:APPDELEGATE.curDevice.device_id keyword:self.keyWords page:page limit:limit statusCode:^(NSInteger code) {
        self.isRequest = NO;
        [Loading dismiss];
    } requestSuccess:^(id _Nonnull data) {
        SearchBean *searchBean = [SearchBean yy_modelWithJSON:data];
        [_self.songsData addObjectsFromArray:searchBean.results];
        [_self.tableView reloadData];
        [_self.footerView hw_toNoMoreState:searchBean.results.count  < limit];
    } requestFail:^(id _Nonnull data) {
        
    }];
}

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
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [Loading show:nil];
    SongBean *song=[self.songsData objectAtIndex:indexPath.row];
    [[IFLYOSSDK shareInstance] musicControlPlay:APPDELEGATE.curDevice.device_id mediaId:song._id sourceType:song.source_type statusCode:^(NSInteger code) {
        [Loading dismiss];
    } requestSuccess:^(id _Nonnull data) {
        [[iToast makeText:[NSString stringWithFormat:NSLocalizedString(@"play_now", nil),song.name]] show];
    } requestFail:^(id _Nonnull data) {
        [[iToast makeText:NSLocalizedString(@"load_music_err", nil)] show];
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


#pragma mark -UIBarPositioningDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self search:searchBar.text];
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

#pragma mark --searchBar懒加载
-(UISearchBar*)searchBar{
    if(!_searchBar){
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 80, 44)];
        _searchBar.delegate = self;
        [[[[_searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
        _searchBar.backgroundColor = [UIColor clearColor];
        _searchBar.layer.borderWidth = 1;
        _searchBar.layer.cornerRadius = 10;
        _searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _searchBar.barTintColor = [UIColor clearColor];
        id s = [_searchBar valueForKeyPath:@"searchField"];
        UIView *searchField = s;
        searchField.backgroundColor = [UIColor clearColor];
        id b = [s valueForKeyPath:@"_clearButton"];
        if([b isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton*)b;
            [btn addTarget:self action:@selector(onCancelInput) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _searchBar;
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
