//
//  IFLYQRCodeView.m
//  smartHome
//
//  Created by 周经伟 on 2018/4/28.
//  Copyright © 2018年 iflytek. All rights reserved.
//

#import "IFLYQRCodeView.h"
#import "UIView+UIView_alertView.h"
@interface IFLYQRCodeView()<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    CAShapeLayer *cropLayer;
    UILabel *tipsLabel;
}
@end

@implementation IFLYQRCodeView

-(void) initScanView{
    self.localImage.layer.masksToBounds = YES;
    self.localImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.localImage.layer.borderWidth = 1;
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:kScanRect];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+10, SCAN_WIDTH, 2)];
    self.line.image = [UIImage imageNamed:@"line.png"];
    [self addSubview:_line];
    
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, TOP+SCAN_WIDTH+50, SCREEN_WIDTH, 50)];
    tipsLabel.font = [UIFont systemFontOfSize:18];
    
    NSString *tipsStr = @"二维码扫描";
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 行间距设置为30
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [paragraphStyle  setLineSpacing:5];
    NSMutableAttributedString  *setString = [[NSMutableAttributedString alloc] initWithString:tipsStr];
    [setString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [tipsStr length])];
    
    tipsLabel.attributedText = setString;
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 0 ;
    [self addSubview:tipsLabel];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
}

- (void)setCropRect:(CGRect)cropRect{
    self.isSuccess = NO;
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    [cropLayer setNeedsDisplay];
    
    [self.layer addSublayer:cropLayer];
    [self bringSubviewToFront:self.localImage];
    
    [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0];
}

- (void)setupCamera
{   
    [self checkAVAuthorizationStatus];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        return;
    }
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = TOP/SCREEN_HEIGHT;
    CGFloat left = LEFT/SCREEN_WIDTH;
    CGFloat width = SCAN_WIDTH/SCREEN_WIDTH;
    CGFloat height = SCAN_WIDTH/SCREEN_HEIGHT;
    ///top 与 left 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *tips = @"您没有权限访问相机,请在设置应用打开相机。";
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        //        [self setupCamera];
    } else {
        [UIView showAlert:@"警告" message:tips target:self.delegate];
        return ;
    }
    // 条码类型 AVMetadataObjectTypeQRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.layer.bounds;
    [self.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}


- (void)checkAVAuthorizationStatus
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *tips = @"您没有权限访问相机,请在设置应用打开相机。";
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
//        [self setupCamera];
    } else {
        
    }
}


-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, SCAN_WIDTH, 2);
        if (2*num == 200) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, SCAN_WIDTH, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
       
        //停止扫描
        [_session stopRunning];
        [timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        //结果回调
        if (!self.isSuccess) {
            [self.delegate callBack:stringValue];
        }
        
         self.isSuccess = YES;
    } else {
        NSLog(@"无扫描信息");
        return;
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if(timer){
        return;
    }
    [self initScanView];
    [self setCropRect:kScanRect];
}


@end
