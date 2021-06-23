//
//  QRCodeViewController.m
//  iflyosSDKDemo
//
//  Created by 周经伟 on 2019/4/3.
//  Copyright © 2019 test. All rights reserved.
//

#import "QRCodeViewController.h"
#import "IFLYQRCodeView.h"
@interface QRCodeViewController ()<IFLYQRCodeDelegate>
@property (strong, nonatomic) IFLYQRCodeView *qrCodeView;
@end

@implementation QRCodeViewController

-(IFLYQRCodeView *) qrCodeView{
    if (!_qrCodeView) {
        _qrCodeView = [[IFLYQRCodeView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _qrCodeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.qrCodeView.delegate = self;
    [self.view addSubview:self.qrCodeView];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.qrCodeView removeFromSuperview];
    _qrCodeView = nil;
}

/**
 *  二维码回调
 *  qrcodeStr : 二维码字符串
 */
-(void) callBack:(NSString *) qrcodeStr{
    NSLog(@"QRCode : %@",qrcodeStr);
   
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


