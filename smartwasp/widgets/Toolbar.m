//
//  Toolbar.m
//  smartwasp
//
//  Created by luotao on 2021/4/19.
//

#import "Toolbar.h"
#import "DeviceDialog.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "AppDelegate.h"
#import "UIView+Extension.h"
#import <Masonry.h>
#import <objc/runtime.h>
#import "MusicPlayViewController.h"
#import "UIImageView+WebCache.h"
#import "LXSEQView.h"
#import "UIViewHelper.h"
#import "SearchViewController.h"
#import "AddDeviceViewController.h"
#import "iToast.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface Toolbar ()

//设备表示状态图标
@property (weak, nonatomic) IBOutlet UIImageView *devStatusIcon;
//设备的名称
@property (weak, nonatomic) IBOutlet UILabel *devNameTxt;
//状态图标
@property (strong,nonatomic) UIImage *statusImage;

@property (weak, nonatomic) IBOutlet UIImageView *combo;
//音乐跳动动画
@property (weak, nonatomic) IBOutlet LXSEQView *jump;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint;
@property (weak, nonatomic) IBOutlet UIButton *searchView;

@end

@implementation Toolbar

-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    return self;
}

//从故事面板加载
-(void)awakeFromNib{
    [super awakeFromNib];
    _statusImage = [UIImage imageNamed:@"icon_status"];
    _devStatusIcon.image = _statusImage;
    _devNameTxt.numberOfLines = 0;
    _devNameTxt.preferredMaxLayoutWidth = SCREEN_WIDTH  / 2.5;
    [UIViewHelper attachClick:self.jump target:self action:@selector(doTapMethod)];
}

//设备选择点击
-(IBAction)onClick:(id)sender {
    if(!APPDELEGATE.curDevice){
        //添加设备
        UIViewController *cvc = [UIViewHelper getAttachController:self];
        AddDeviceViewController *avc = AddDeviceViewController.new;
        [cvc.navigationController pushViewController:avc animated:YES];
        return;
    }
    [DeviceDialog create];
}

//音乐控件点击
-(void)doTapMethod{
    if(!APPDELEGATE.curDevice){
        [[iToast makeText:@"暂无设备"] show];
        return;
    }
    UIViewController *cvc = [UIViewHelper getAttachController:self];
    if(cvc){
        MusicPlayViewController *mvc = MusicPlayViewController.new;
        [cvc.navigationController pushViewController:mvc animated:YES];
    }
}


-(void)layoutSubviews{
    _searchView.hidden = !self.canSearch;
}

- (IBAction)onSearchClick:(id)sender {
    if(!APPDELEGATE.curDevice){
        [[iToast makeText:@"暂无设备"] show];
        return;
    }
    SearchViewController *svc = SearchViewController.new;
    UIViewController *cvc = [UIViewHelper getAttachController:self];
    [cvc.navigationController pushViewController:svc animated:YES];
}

//添加设备信息
-(void)setDevice:(DeviceBean *)device{
    _device = device;
    if(_device){
        [self update];
    }else{
        [self setEmpty];
    }
}

//更新设备信息
-(void)update{
    [self setDevStatus:_device.isOnLine];
    [self setDevName:_device.alias];
}

//设置设备是否在线
-(void)setDevStatus:(Boolean) isOnline{
    _devStatusIcon.hidden = false;
    _combo.hidden = false;
    _devStatusIcon.tintColor = [UIColor colorWithHexString:isOnline  ?  @"#03F484":@"#B8B8B8"];
    self.constraint.priority = 999;
}

//设置设备名称
-(void)setDevName:(NSString*)devName{
    _devNameTxt.text = devName;
}

//设置暂无设备
-(void)setEmpty{
    _devStatusIcon.hidden = true;
    _combo.hidden = true;
    _devNameTxt.text = @"请添加设备";
    self.constraint.priority = 250;
}

//音乐开始跳动
- (void)startJump{
    if(!self.jump)
        return;
    [self.jump startAnimation];
}

//音乐停止跳动
- (void)stopJump{
    if(!self.jump)
        return;
    [self.jump stopAnimation];
}

//静态生成
+(Toolbar*)newView{
    return  [[[NSBundle mainBundle] loadNibNamed:@"Toolbar" owner:nil options:nil] lastObject];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
