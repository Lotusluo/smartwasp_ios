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
#import <Masonry.h>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface Toolbar ()

//设备表示状态图标
@property (weak, nonatomic) IBOutlet UIImageView *devStatusIcon;
//设备的名称
@property (weak, nonatomic) IBOutlet UILabel *devNameTxt;
//状态图标
@property (strong,nonatomic) UIImage *statusImage;

@property (weak, nonatomic) IBOutlet UIImageView *combo;


@end

@implementation Toolbar

//从故事面板加载
-(void) awakeFromNib{
    [super awakeFromNib];
    _statusImage = [UIImage imageNamed:@"icon_status"];
    _devStatusIcon.image = _statusImage;
    _devNameTxt.numberOfLines = 0;
    _devNameTxt.preferredMaxLayoutWidth = SCREEN_WIDTH  / 2.5;
}

//设备选择点击
- (IBAction)onClick:(id)sender {
    __weak typeof(self) __SELF = self;
    [DeviceDialog create];
    
}


//设置设备是否在线
- (void) setDevStatus:(Boolean) isOnline{
    _devStatusIcon.hidden = false;
    _combo.hidden = false;
    _devStatusIcon.tintColor = [UIColor colorWithHexString:isOnline  ?  @"#03F484":@"#B8B8B8"];
    [_devNameTxt mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_devStatusIcon.mas_trailing).offset(15);
    }];
}

//设置设备名称
- (void) setDevName:(NSString*)devName{
    _devNameTxt.text = devName;
}

//设置暂无设备
- (void) setEmpty{
    [_devNameTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
    }];
    _devStatusIcon.hidden = true;
    _combo.hidden = true;
    _devNameTxt.text = @"请添加设备";
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
