//
//  GroupView.m
//  smartwasp
//
//  Created by luotao on 2021/6/2.
//

#import "GroupView.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry.h>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define GROUP_COL 3

@interface GroupView()<
UICollectionViewDataSource,
UICollectionViewDelegate
>
//标题名称
@property (weak, nonatomic) IBOutlet UILabel *abbrLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
//组视图
@property (weak, nonatomic) IBOutlet UICollectionView *groupView;
//组视图布局
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *groupViewLayout;

@property (nonatomic)BOOL canLoad;

@end

@implementation GroupView

static NSString *const ID = @"CellIdentifier";

-(void) awakeFromNib{
    [super awakeFromNib];
    self.moreBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self setupCollectionView];
}

//设置集合视图布局
- (void)setupCollectionView {
    //先计算每个格子宽度
    CGFloat itemWidth = (SCREEN_WIDTH - (4 * 20)) / GROUP_COL;
    _groupViewLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 20);
    _groupViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 20, 0);
    _groupViewLayout.minimumInteritemSpacing = 10;
    [_groupView registerNib:[UINib nibWithNibName:@"GroupItemCell" bundle:nil] forCellWithReuseIdentifier:ID];
}

//获取控件高度
-(CGFloat)uiHeight{
    CGFloat itemHeight = (SCREEN_WIDTH - (4 * 20)) / GROUP_COL + 20;
    int row = ceilf(self.groupBean.items.count / GROUP_COL);
    return 18 + 10 + 20 + ((row - 1) * 20) + (row) * itemHeight;
}

//设置组数据
-(void)setGroupBean:(GroupBean *)groupBean{
    _groupBean = groupBean;
    _abbrLabel.text = groupBean.name;
    _moreBtn.hidden = !groupBean.has_more;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo([self uiHeight]);
    }];
}

//更多点击
- (IBAction)onMoreClick:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(groupView:onClickMore:)]){
        [self.delegate groupView:self onClickMore:self.groupBean];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self checkToLoad];
}

-(void)checkToLoad{
    if(!self.canLoad){
        UIView *parent = self.superview.superview.superview;
        CGRect visRect = parent.frame;
        CGRect tranRect = [self convertRect:(self.bounds) toView:parent];
        if(!CGRectIsNull(CGRectIntersection(visRect, tranRect))){
            self.canLoad = YES;
            [self.groupView reloadData];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return ceilf(self.groupBean.items.count / GROUP_COL);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return GROUP_COL;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static UIImage *placeholderImage = nil;
    if (!placeholderImage) {
        placeholderImage = [UIImage imageNamed:@"placeholder"];
    }
    UICollectionViewCell *cell = [self. groupView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    if(self.canLoad){
        NSInteger idx = indexPath.section * GROUP_COL + indexPath.row;
        if (self.groupBean.items.count <= idx) {
            return cell;
        }
        ItemBean *bean = self.groupBean.items[idx];
        UIImageView *imageView = cell.subviews[0];
        CGFloat itemWidth = (SCREEN_WIDTH - (4 * 20)) / GROUP_COL;
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(itemWidth);
        }];
        imageView.sd_imageTransition = SDWebImageTransition.fadeTransition;
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayIndicator;
        [imageView sd_setImageWithURL:[NSURL URLWithString:bean.image] placeholderImage:placeholderImage];
        UILabel *label = cell.subviews[1];
        label.text = bean.name;
    }

//    int R = (arc4random() % 256) ;
//    int G = (arc4random() % 256) ;
//    int B = (arc4random() % 256) ;
//    cell.backgroundColor =[UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
    
    return cell;
}

#pragma mark --UICollectionViewDelegate
-( void )collectionView:( UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    NSInteger idx = indexPath.section * GROUP_COL + indexPath.row;
    if (self.groupBean.items.count <= idx)
        return ;
    ItemBean *bean = self.groupBean.items[idx];
    if(self.delegate && [self.delegate respondsToSelector:@selector(groupView:canClickItemAtIndex:)]){
        [self.delegate groupView:self canClickItemAtIndex:bean];
    }
}


-(void)setDelegate:(id<ISelectedDelegate>)delegate{
    _delegate = delegate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//静态生成
+(GroupView*)newView{
    return  [[[NSBundle mainBundle] loadNibNamed:@"GroupView" owner:nil options:nil] lastObject];
}

@end
