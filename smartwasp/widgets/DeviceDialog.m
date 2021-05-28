//
//  DcCDialog.m
//  smartwasp
//
//  Created by luotao on 2021/4/23.
//

#import "DeviceDialog.h"
#import "DeviceChooseCell.h"
#import "Device.h"
#import <Masonry.h>
#import "AppDelegate.h"

#define CELL_HEIGHT 40.0f
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface DeviceDialog ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate>

//设备选择列表
@property (weak, nonatomic) IBOutlet UITableView *devList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *devListHeight;
//回调函数
@property(strong,nonatomic) didSelectIndex delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *safeBottom;
//mask
@property(weak,nonatomic) UIView *mask;

@end

@implementation DeviceDialog

//已从xib加载
- (void)awakeFromNib{
    [super awakeFromNib];
    //注册UITableView及相关配置
    [_devList registerNib:[UINib nibWithNibName:@"DeviceChooseCell" bundle:nil] forCellReuseIdentifier:@"DeviceChooseCell"];
    _devList.dataSource = self;
    _devList.delegate = self;
    _devList.showsVerticalScrollIndicator = NO;
    _devList.showsHorizontalScrollIndicator = NO;
    //设置当前选中的设备
    NSUInteger index = [APPDELEGATE.devices indexOfObject:APPDELEGATE.curDevice];
    NSIndexPath *ip=[NSIndexPath indexPathForRow:index inSection:0];
    [_devList selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionBottom];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    //动态布局
    _devListHeight.constant = MIN(CELL_HEIGHT * (APPDELEGATE.devices.count + 1), 250);
    _safeBottom.constant = sgm_safeAreaInset(self).bottom;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(_devListHeight.constant + _safeBottom.constant + 50 + 10);
        make.bottom.equalTo(self.superview);
    }];
    [self doFadeIn:true];
}

#pragma mark -UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//数据长度
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return APPDELEGATE.devices.count;
}

//数据控件赋值
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"DeviceChooseCell";
    DeviceChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Device *optionItem = [APPDELEGATE.devices objectAtIndex:indexPath.row];
    [cell setDevName:optionItem.alias];
    [cell setDevStatus:optionItem.isOnLine];
    return cell;
}

#pragma mark -UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

//Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CELL_HEIGHT;
}

//设置footer
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//   iOS 11设置 header 高度必须同时实现  viewForHeaderInSection 和  heightForHeaderInSection ；
//   iOS 11 之前版本只设置  heightForHeaderInSection 即可设置   header 高度，只是在  UITableViewStyleGrouped   时无法设置 header 高度为0，设置0时高度为系统默认高度
    static NSString *footerSectionID = @"cityHeaderSectionID";
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerSectionID];
    if (footerView == nil){
        footerView =  [[[NSBundle mainBundle] loadNibNamed:@"DeviceAddCell" owner:nil options:nil] lastObject];
        footerView.contentView.backgroundColor = [UIColor whiteColor];
    }
    return footerView;
}

//cell被点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *optionItem = [APPDELEGATE.devices objectAtIndex:indexPath.row];
    AppDelegate* app  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.curDevice = optionItem;
    [self dismiss:nil];
}

//上一个被选择的cell
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 3.0, *)) {
        
    }
}

//构建弹出框
+(DeviceDialog*)create{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    //添加mask
    UIView *mask = [[UIView alloc] initWithFrame:keyWindow.screen.bounds];
    mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2 ];
    [keyWindow addSubview:mask];
    //添加底视图
    DeviceDialog* dialog = [[[NSBundle mainBundle] loadNibNamed:@"DeviceDialog" owner:nil options:nil] lastObject];
    [keyWindow addSubview:dialog];
    dialog.mask = mask;
    UITapGestureRecognizer *click=[[UITapGestureRecognizer alloc]initWithTarget:dialog action:@selector(dismiss:)];
    [mask addGestureRecognizer:click];
    return dialog;
}

//取消弹出框
- (IBAction)dismiss:(id)sender {
    [self doFadeIn:false];
}

//弹出框动画效果
-(void) doFadeIn:(Boolean) flag{
    [self.layer removeAllAnimations];
    CABasicAnimation *transAnimation  = [CABasicAnimation animationWithKeyPath:@"position"];
    transAnimation.delegate = self;
    CGPoint fromValue = self.layer.position;
    CGPoint toValue = self.layer.position;
    if(flag){
        fromValue.y += self.frame.size.height;
    }else{
        toValue.y += self.frame.size.height;
    }
    transAnimation.fromValue =  [NSValue valueWithCGPoint: fromValue];
    transAnimation.toValue = [NSValue valueWithCGPoint:toValue];
    transAnimation.duration = 0.2;
    transAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:transAnimation forKey:[NSString stringWithFormat:@"position:%d",flag]];
    
    //透明度变化
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:flag ? 0 : 1];
    opacityAnimation.toValue = [NSNumber numberWithFloat:flag ? 1 : 0];
    opacityAnimation.duration = 0.2;
    [self.mask.layer addAnimation:opacityAnimation forKey:@"opacity"];
}

#pragma mark --CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if([self.layer animationForKey:[NSString stringWithFormat:@"position:%d",false]] ==  anim && flag){
        [self removeFromSuperview];
        if(self.mask){
            [self.mask removeFromSuperview];
        }
    }
}

@end
