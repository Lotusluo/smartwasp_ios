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
#import "IFLYOSSDK.h"
#import "Loading.h"
#import "NSObject+YYModel.h"


NSString *SSID = @"";
NSString *PWD = @"";
ApAuthCode *AUTHCODE;

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
        self.titleView.text = NSLocalizedString(@"net_set", nil);
        self.labelHeader.text = NSLocalizedString(@"net_set1", nil);;
        self.labelFooter.text = NSLocalizedString(@"net_set2", nil);;
        NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"ic_dangjian@2x.png" ofType:nil];
        self.imageView.image = [UIImage imageWithContentsOfFile:bundleStr];

    }
    self.nextBtn.enabled = self.checkBox.selected;
}

-(void)onHotAreaClick{
    [self.checkBox setSelected:!self.checkBox.selected animated:YES];
    self.nextBtn.enabled = self.checkBox.selected;
}


- (IBAction)onNextClick:(id)sender {
    if(self.mBindType == NO_SCREEN_TYPE){
        //获取授权码
        [Loading show:nil];
        [[IFLYOSSDK shareInstance] getAuthCode:@"65e8d4f8-da9e-4633-8cac-84b0b47496b6"
                                    statusCode:^(NSInteger code) {
            [Loading dismiss];
        } requestSuccess:^(id _Nonnull data) {
            AUTHCODE = [ApAuthCode yy_modelWithJSON:data];
            WaitLAViewController *wvc = WaitLAViewController.new;
            [self.navigationController pushViewController:wvc animated:YES];
        } requestFail:^(id _Nonnull data) {
            
        }];
    }else{
        QRCodeViewController *qvc = QRCodeViewController.new;
        [self.navigationController pushViewController:qvc animated:YES];
    }
}

//销毁
-(void)dealloc{
    SSID = nil;
    PWD = nil;
    AUTHCODE = nil;
    NSLog(@"PrevBindViewController dealloc");
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
