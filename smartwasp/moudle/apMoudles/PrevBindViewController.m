//
//  PrevBindViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/24.
//

#import "PrevBindViewController.h"
#import "QRCodeViewController.h"
#import "WaitLAViewController.h"
#import "UIViewHelper.h"
#import "ZFCheckbox.h"


@interface PrevBindViewController ()

@property (weak, nonatomic) IBOutlet UIStackView *hotArea;
@property (weak, nonatomic) IBOutlet ZFCheckbox *checkBox;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelFooter;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation PrevBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
    [UIViewHelper attachClick:self.hotArea target:self action:@selector(onHotAreaClick)];
    // Do any additional setup after loading the view from its nib.
}

//更新UI
-(void)updateUI{
    if(self.mBindType == NO_SCREEN_TYPE){
        self.titleView.text = @"设备进入配网模式";
        self.labelHeader.text = @"接通电源,设备开机,长按静音键,进入配网模式";
        self.labelFooter.text = @"设备正在配网";
        NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"ic_dangjian.png" ofType:nil];
        self.imageView.image = [UIImage imageWithContentsOfFile:bundleStr];

    }
    self.nextBtn.enabled = self.checkBox.selected;
}

-(void)onHotAreaClick{
    [self.checkBox setSelected:!self.checkBox.selected animated:YES];
    self.nextBtn.enabled = self.checkBox.selected;
}

- (IBAction)onBackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNextClick:(id)sender {
    if(self.mBindType == NO_SCREEN_TYPE){
        //获取授权码
        WaitLAViewController *wvc = WaitLAViewController.new;
        [self.navigationController pushViewController:wvc animated:YES];
    }else{
        QRCodeViewController *qvc = QRCodeViewController.new;
        [self.navigationController pushViewController:qvc animated:YES];
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
