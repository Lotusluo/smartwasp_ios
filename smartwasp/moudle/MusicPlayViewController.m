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
#import "NormalToolbar.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface MusicPlayViewController ()

@property (weak, nonatomic) IBOutlet NormalToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation MusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self attach];
}

-(void)attach{
    DeviceBean *device = APPDELEGATE.curDevice;
    [self updateToolbarUI:device];
}

//更新toobarUI
-(void)updateToolbarUI:(DeviceBean*)device{
    UIImage *image =[UIImage imageNamed:@"icon_status"];
    UIColor *color = [UIColor colorWithHexString:device.isOnLine ?  @"#03F484":@"#B8B8B8"];
    UILabel *titleView = self.toolBar.txtView;
    titleView.text = device.name;
    [titleView setLeftSquareDrawable:[image renderImageWithColor:color]];
}


- (IBAction)onPlayOrPause:(id)sender {
    
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
