//
//  MusicPlayViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/16.
//

#import "MusicPlayViewController.h"
#import "AppDelegate.h"
#import "UILabel+Extension.h"
#import "UIImage+Extension.h"
#import "DeviceBean.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "UIImageView+WebCache.h"
#import "IFLYOSSDK.h"
#import "UIViewHelper.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface MusicPlayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *playView;
@property (weak, nonatomic) IBOutlet UILabel *cpView;


@end

@implementation MusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateToolbarUI:APPDELEGATE.curDevice];
//    _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_imageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
//    maskLayer.frame = _imageView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    _imageView.layer.mask = maskLayer;
    self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds cornerRadius:100.0].CGPath;
    self.navigationItem.titleView = self.titleView;
}


//更新toobarUI
-(void)updateToolbarUI:(DeviceBean*)device{
    UIImage *image =[UIImage imageNamed:@"icon_status"];
    UIColor *color = [UIColor colorWithHexString:device.isOnLine ?  @"#03F484":@"#B8B8B8"];
    self.titleView.text = device.name;
    [self.titleView setLeftSquareDrawable:[image renderImageWithColor:color]];
}


- (IBAction)onPlayOrPause:(id)sender {
    if(self.playView.selected){
        //暂停
        [[IFLYOSSDK shareInstance] musicControlStop:APPDELEGATE.curDevice.device_id statusCode:^(NSInteger code) {
        } requestSuccess:^(id _Nonnull data) {
        } requestFail:^(id _Nonnull data) {
        }];
    }else{
        //恢复
        [[IFLYOSSDK shareInstance] musicControlResume:APPDELEGATE.curDevice.device_id statusCode:^(NSInteger code) {
        } requestSuccess:^(id _Nonnull data) {
        } requestFail:^(id _Nonnull data) {
        }];
    }
}

//上一首
- (IBAction)onForward:(id)sender {
    [[IFLYOSSDK shareInstance] musicControlPrevious:APPDELEGATE.curDevice.device_id statusCode:^(NSInteger code) {
    } requestSuccess:^(id _Nonnull data) {
    } requestFail:^(id _Nonnull data) {
    }];
}

//下一首
- (IBAction)onBackward:(id)sender {
    [[IFLYOSSDK shareInstance] musicControlNext:APPDELEGATE.curDevice.device_id statusCode:^(NSInteger code) {
    } requestSuccess:^(id _Nonnull data) {
    } requestFail:^(id _Nonnull data) {
    }];
}

//音量调节
- (IBAction)voiceChangedClick:(id)sender {
    [[IFLYOSSDK shareInstance] musicControlVolume:APPDELEGATE.curDevice.device_id volume:self.sliderView.value statusCode:^(NSInteger code) {
    } requestSuccess:^(id _Nonnull data) {
    } requestFail:^(id _Nonnull data) {
    }];
}

//处理设备媒体状态通知
-(void)mediaSetCallback:(MusicStateBean* __nullable) musicStateBean{
    if(musicStateBean){
        if(musicStateBean.music.source && [musicStateBean.music.source isEqualToString:@""]){
            self.cpView.text = [NSString stringWithFormat:@"版权所有：%@",musicStateBean.music.source];
        }else{
            self.cpView.text = @"暂无来源";
        }
        self.sliderView.value = musicStateBean.speaker.volume;
        self.playView.selected = musicStateBean.isPlaying;
        self.nameView.text = musicStateBean.music.name ? musicStateBean.music.name : NSLocalizedString(@"un_play_now1", nil);
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:musicStateBean.music.image]];
    }
}

//设备在线状态变更
-(void)onLineChangedCallback{
    [self updateToolbarUI:APPDELEGATE.curDevice];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(NEED_TIP){
        [UIViewHelper showAlert:NSLocalizedString(@"song_play_tip", nil) target:self];
        NEED_TIP = NO;
    }
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
