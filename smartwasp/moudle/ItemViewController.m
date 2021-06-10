//
//  ItemViewController.m
//  smartwasp
//
//  Created by luotao on 2021/6/10.
//

#import "ItemViewController.h"
#import "NormalToolbar.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"
#import "AppDelegate.h"
#import <Masonry.h>

@interface ItemViewController ()

//toolbar
@property (weak, nonatomic) IBOutlet NormalToolbar *toolBar;
//模糊的底图
@property (weak, nonatomic) IBOutlet UIImageView *blurImage;
//数据
@property (strong,nonatomic) ItemBean *bean;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UILabel *fromView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHeight;

@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolBar.title = @"歌单";
    if (@available(iOS 11.0, *)) {
        if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    [self attchUI];
    // Do any additional setup after loading the view from its nib.
}

-(void) attchUI{
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.view.mas_height).multipliedBy(0.3);
    }];
    self.nameView.text = self.bean.name;
    self.fromView.text =  self.bean.from;
    self.blurImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.blurImage sd_setImageWithURL:[NSURL URLWithString:self.bean.image] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(image){
            __weak typeof(self) _self = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *blur = [UIImage imageBlurImage:image WithBlurNumber:0.5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _self.blurImage.image = blur;
                });
            });
        }
    }];
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:self.bean.image]];
}

-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.iconHeight.constant = sgm_safeAreaInset(self.view).bottom + 49 + 10;
}

+(ItemViewController *) createNewPage:(ItemBean *) bean{
    ItemViewController *vc = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
    vc.bean = bean;
    return vc;
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
