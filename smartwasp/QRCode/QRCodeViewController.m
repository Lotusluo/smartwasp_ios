//
//  QRCodeViewController.m
//  iflyosSDKDemo
//
//  Created by 周经伟 on 2019/4/3.
//  Copyright © 2019 test. All rights reserved.
//

#import "QRCodeViewController.h"
#import "IFLYQRCodeView.h"
@interface QRCodeViewController ()<IFLYQRCodeDelegate>{
    
}
@property (weak, nonatomic) IBOutlet UIButton *naviBtn;
@property (strong, nonatomic) IFLYQRCodeView *qrCodeView;
@end

@implementation QRCodeViewController

-(IFLYQRCodeView *)qrCodeView{
    if (!_qrCodeView) {
        _qrCodeView = [[IFLYQRCodeView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _qrCodeView;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.qrCodeView.delegate = self;
    [self.view addSubview:self.qrCodeView];
    [self.view bringSubviewToFront:self.naviBtn];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.qrCodeView removeFromSuperview];
    _qrCodeView = nil;
}

/**
 *  二维码回调
 *  qrcodeStr : 二维码字符串
 */
-(void)callBack:(NSString *)qrcodeStr{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"qrCodeNotification" object:qrcodeStr userInfo:nil];
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


