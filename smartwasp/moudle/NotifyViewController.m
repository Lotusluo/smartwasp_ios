//
//  BaseTabViewController.m
//  smartwasp
//
//  Created by luotao on 2021/4/20.
//

#import "NotifyViewController.h"
#import "AppDelegate.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)


@interface NotifyViewController ()

@end

@implementation NotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //对选择的设备进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devSetObserver:)
                                                 name:@"devSetNotification"
                                               object:nil];
    //对媒体状态进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaSetObserver:)
                                                 name:@"mediaSetNotification"
                                               object:nil];
    //对设备在线状态进行监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLineChangedSetObserver:)
                                                 name:@"onLineChangedNotification"
                                               object:nil];
    // Do any additional setup after loading the view.
}

#pragma mark --处理设备选择通知
-(void)devSetObserver:(NSNotification*)notification {
    [self devSetCallback:APPDELEGATE.curDevice];
}

-(void)devSetCallback:(DeviceBean* __nullable) device{
    
}

#pragma mark --处理设备媒体状态通知
-(void)mediaSetObserver:(NSNotification*)notification {
    if(APPDELEGATE.mediaStatus){
        [self mediaSetCallback:APPDELEGATE.mediaStatus.data];
        return;
    }
    [self mediaSetCallback:nil];
}

-(void)mediaSetCallback:(MusicStateBean* __nullable) musicStateBean{
    
}

#pragma mark --处理设备在线状态通知
-(void)onLineChangedSetObserver:(NSNotification*)notification {
    [self onLineChangedCallback];
}

-(void)onLineChangedCallback{
  
}

//视图将要被呈现
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self mediaSetObserver:nil];
}

//视图将要消失
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self mediaSetObserver:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
