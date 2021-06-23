//
//  IFLYQRCodeView.h
//  smartHome
//
//  Created by 周经伟 on 2018/4/28.
//  Copyright © 2018年 iflytek. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "IFLYQRCodeUtils.h"

@protocol IFLYQRCodeDelegate<NSObject>
/**
 *  二维码回调
 *  qrcodeStr : 二维码字符串
 */
-(void) callBack:(NSString *) qrcodeStr;
@end
/**
 *  屏幕 高 宽 边界
 */

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define SCAN_WIDTH 300 //扫描框
#define TOP (SCREEN_HEIGHT-SCAN_WIDTH)/3
#define LEFT (SCREEN_WIDTH-SCAN_WIDTH)/2

#define kScanRect CGRectMake(LEFT, TOP, SCAN_WIDTH, SCAN_WIDTH)
@interface IFLYQRCodeView : UIView

@property (nonatomic) id<IFLYQRCodeDelegate> delegate;

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, strong) UIImageView * line;
@property (weak, nonatomic) IBOutlet UIButton *localImage;

@property (nonatomic) BOOL isSuccess;//扫描成功

-(void) initScanView;
- (void)setCropRect:(CGRect)cropRect;
- (void)setupCamera;
@end
