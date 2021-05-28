//
//  DeviceChooseCell.m
//  smartwasp
//
//  Created by luotao on 2021/4/25.
//

#import "DeviceChooseCell.h"
#import "IFLYOSUIColor+IFLYOSColorUtil.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)



@interface DeviceChooseCell ()

@property (weak, nonatomic) IBOutlet UIImageView *devStatusIcon;

@property (weak, nonatomic) IBOutlet UILabel *devNameTxt;

@property (weak, nonatomic) IBOutlet UILabel *devStatusTip;

@property (weak, nonatomic) IBOutlet UIImageView *devSelectedIcon;

@end

@implementation DeviceChooseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _devStatusIcon.image = [UIImage imageNamed:@"icon_status"];
    _devSelectedIcon.image = [UIImage imageNamed:@"icon_yes"];
    _devNameTxt.numberOfLines = 0;
    _devNameTxt.preferredMaxLayoutWidth = SCREEN_WIDTH  / 2.5;
    // Initialization code
}

//设置设备是否在线
- (void) setDevStatus:(Boolean) isOnline{
    _devStatusIcon.tintColor = [UIColor colorWithHexString:isOnline  ?  @"#03F484":@"#B8B8B8"];
    _devStatusTip.text = isOnline ? @"设备在线" : @"设备离线";
}

//设置设备名称
- (void) setDevName:(NSString*)devName{
    _devNameTxt.text = devName;
}

//是否被点击
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor =  [UIColor colorWithHexString:selected  ?  @"#F0E8E8":@"#FFFFFF"];
    self.devSelectedIcon.hidden = !selected;
}

@end
