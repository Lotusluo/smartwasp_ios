//
//  NormalNaviCell.m
//  smartwasp
//
//  Created by luotao on 2021/5/28.
//

#import "NormalNaviCell.h"
#import <Masonry.h>
@interface NormalNaviCell()

@property(nonatomic,strong) UIImageView *leftImage;
@end

@implementation NormalNaviCell

-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if(self){
        [self initUI];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initUI];
    }
    return self;
}

-(void) awakeFromNib{
    [super awakeFromNib];
    _leftImage.image = _leftIcon;
    [self.leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self);
    }];
}

//初始化UI界面
-(void)initUI{
    //添加左侧ICON
    _leftImage = [UIImageView new];
    [self addSubview:_leftImage];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
