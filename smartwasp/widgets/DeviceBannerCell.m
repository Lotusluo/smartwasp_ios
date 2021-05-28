//
//  DeviceBannerCell.m
//  smartwasp
//
//  Created by luotao on 2021/5/18.
//

#import "DeviceBannerCell.h"
#import "UIView+Extension.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Extension.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "UIImage+Extension.h"

@interface DeviceBannerCell()

//主控界面UI
@property (weak, nonatomic) IBOutlet UIView *headerUI;
//设备界面UI
@property (weak, nonatomic) IBOutlet UIView *deviceUI;

@end

@implementation DeviceBannerCell

- (instancetype) initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if(self){
        //画外边框
        self.borderColor =  [UIColor lightGrayColor];
        self.cornerRadius = 15;
        self.borderWidth = 1;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//渲染设备信息控件
-(void) render:(Device*) device{
    _device = device;
    _headerUI.hidden = YES;
    _deviceUI.hidden = YES;
    if([_device.alias isEqualToString:@"header"]){
        //添加主控设备
        [self drawHeader];
    }else{
        //添加设备信息
        [self drawDevice];
    }
}

//添加主控设备界面
-(void) drawHeader{
    _headerUI.hidden = NO;
    //画虚线内边框
    if(_headerUI.tag != 1){
        CAShapeLayer *dash = [CAShapeLayer layer];
        dash.strokeColor = [UIColor lightGrayColor].CGColor;
        dash.fillColor = nil;
        dash.lineDashPattern = @[@4, @2];
        dash.path = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(12, 15, 12, 15)) cornerRadius:10].CGPath;
        [_headerUI.layer addSublayer:dash];
        [_headerUI setTag:1];
        
        //将图标改变颜色
        UIStackView *lineLayout =  [_headerUI.subviews objectAtIndex:0 ];
        UIImageView *headerIcon = [lineLayout.subviews objectAtIndex:0];
        headerIcon.image = [UIImage imageNamed:@"icon_add"];
    }
}

//添加设备界面
-(void) drawDevice{
    
    _deviceUI.hidden = NO;
    UIImageView *deviceIcon = [_deviceUI.subviews objectAtIndex:0];
    [deviceIcon sd_setImageWithURL:[NSURL URLWithString:_device.image]];
    
    UILabel *deviceName = [_deviceUI.subviews objectAtIndex:1];
    deviceName.text = _device.alias;
    
    UIStackView *lineLayout =  [_deviceUI.subviews objectAtIndex:2 ];
    UILabel *onlineTxt = [lineLayout.subviews objectAtIndex:0];
    UILabel *positionTxt = [lineLayout.subviews objectAtIndex:2];
    positionTxt.text = _device.zone;
    
    UIImage *image =[UIImage imageNamed:@"icon_status"];
    UIColor *color = [UIColor colorWithHexString:_device.isOnLine ?  @"#03F484":@"#B8B8B8"];
    onlineTxt.text  = _device.isOnLine ? @"在线" : @"离线";
    [onlineTxt setDrawable:[image renderImageWithColor:color]];
}

@end


//NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
//UIImage *image =[UIImage imageNamed:@"ic_add_white"];
//NSTextAttachment *attach = [[NSTextAttachment alloc]init];
//image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//attach.image = image;
//attach.bounds = CGRectMake(0, -5, 20, 20);
//NSAttributedString *picStr = [NSAttributedString attributedStringWithAttachment:attach];
//[str appendAttributedString:picStr];
//NSAttributedString *childStr2 = [[NSAttributedString alloc]initWithString:@"增加主控设备"];
//[str appendAttributedString:childStr2];
//_iconLabel.attributedText = str;

//-(void)drawPlaceholderInRect:(CGRect)rect {
//    // 计算占位文字的 Size
//    CGSize placeholderSize = [self.placeholder sizeWithAttributes:
//                              @{NSFontAttributeName : self.font}];
//
//    CGRect drawRect = CGRectMake(0, (rect.size.height - placeholderSize.height)/2, rect.size.width, rect.size.height);
//
//    NSDictionary *attributes = @{NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.8],NSFontAttributeName : self.font};
//
//    [self.placeholder drawInRect:drawRect withAttributes:attributes];
//}
