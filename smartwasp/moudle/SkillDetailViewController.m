//
//  SkillDetailViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/18.
//

#import "SkillDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extension.h"
#import <Masonry.h>
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
#import "InsetsLabel.h"
#import "NormalToolbar.h"


@interface SkillDetailViewController ()

@property (weak, nonatomic) IBOutlet NormalToolbar *toolBar;
//图标控件
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
//专辑名称控件
@property (weak, nonatomic) IBOutlet UILabel *titleView;
//开发者信息控件
@property (weak, nonatomic) IBOutlet UILabel *coView;
@property (weak, nonatomic) IBOutlet UILabel *coView1;
//引导语
@property (weak, nonatomic) IBOutlet UILabel *guideView;
//提示语控件
@property (weak, nonatomic) IBOutlet UILabel *tipView;
//技能对话控件
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//版本信息控件
@property (weak, nonatomic) IBOutlet UILabel *versionView;
//更新时间控件
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UIStackView *skillViewContainer;

@end

@implementation SkillDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"技能详情";
    [self attachUI];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.skillViewContainer.height);
}

//赋值UI
-(void)attachUI{
    if(!self.skillBean)
        return;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:self.skillBean.icon]];
    self.titleView.text = self.skillBean.shopName;
    self.coView.text = self.skillBean.developer;
    self.coView1.text = self.skillBean.developer;
    self.tipView.text = self.skillBean.skillDesc;
    self.versionView.text = self.skillBean.version;
    self.timeView.text = self.skillBean.updateTime;
    if(self.skillBean.hitTextS.count > 0){
        self.guideView.text = [NSString stringWithFormat:@"您可以说 %@",self.skillBean.hitTextS[0]];
        __block NSInteger index = 0;
        for(NSString *skillStr in self.skillBean.hitTextS){
            InsetsLabel *skillView = InsetsLabel.new;
            skillView.rightInset = 10;
            skillView.leftInset = 10;
            skillView.preferredMaxLayoutWidth = self.view.width - 10;
            skillView.text = skillStr;
            skillView.textColor = [UIColor whiteColor];
            skillView.backgroundColor = [UIColor colorWithHexString:@"#f6921e"];
            [skillView acs_radiusWithRadius:15 corner:(UIRectCornerTopLeft |
                                                       UIRectCornerTopRight |
                                                       UIRectCornerBottomRight)];
            [skillView sizeToFit];
            [self.skillViewContainer addArrangedSubview:skillView];
            [skillView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(30);
                make.leading.mas_equalTo(5);
                if(++index>=self.skillBean.hitTextS.count){
                    make.bottom.equalTo(self.skillViewContainer);
                }
            }];
        }
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

//静态方式生成ViewController
+(SkillDetailViewController *) createNewPage:(SkillBean *) skillBean{
    SkillDetailViewController *svc = [[SkillDetailViewController alloc] initWithNibName:@"SkillDetailViewController" bundle:nil];
    svc.skillBean = skillBean;
    return svc;
}

@end
