//
//  NormalNaviCell.m
//  smartwasp
//
//  Created by luotao on 2021/5/28.
//

#import "NormalNaviCell.h"
#import <Masonry.h>
#import "IFLYOSUIColor+IFLYOSColorUtil.h"
@interface NormalNaviCell()<UIGestureRecognizerDelegate>

//左侧图标
@property(nonatomic,strong) UIImageView *leftImage;
//标题
@property(nonatomic,strong) UILabel *titleTxt;
//右侧图标
@property(nonatomic,strong) UIImageView *rightImage;

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
        make.leading.mas_equalTo(20);
    }];
    
    _rightImage.image = _rightIcon;
    _rightImage.transform = CGAffineTransformMakeRotation(M_PI);
    _rightImage.tintColor = [UIColor colorWithHexString:@"#8A8A8A"];
    [self.rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(15);
        make.centerY.equalTo(self);
        make.trailing.mas_equalTo(self).offset(-20);
    }];
    
    _titleTxt.text = _title;
    [self.titleTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(_leftImage.mas_trailing).offset(10);
        make.trailing.equalTo(_rightImage);
    }];
}

//初始化UI界面
-(void)initUI{
    //添加左侧ICON
    _leftImage = [UIImageView new];
    [self addSubview:_leftImage];
    
    //添加文本
    _titleTxt = [UILabel new];
    _titleTxt.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleTxt];
    
    //添加右侧ICON
    _rightImage = [UIImageView new];
    [self addSubview:_rightImage];
    
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doCallMethod:)];
    recognizer.delegate = self;
    recognizer.minimumPressDuration = 0.0;
    [self addGestureRecognizer:recognizer];
}

- (void)doCallMethod:(UILongPressGestureRecognizer*)sender {
    if(sender.state == UIGestureRecognizerStateBegan){
        self.backgroundColor = [UIColor lightTextColor];
    }else if (sender.state == UIGestureRecognizerStateChanged){
        sender.enabled = NO;
    }else if (sender.state == UIGestureRecognizerStateCancelled){
        self.backgroundColor = [UIColor whiteColor];
        sender.enabled = YES;
    }else if (sender.state == UIGestureRecognizerStateEnded){
        self.backgroundColor = [UIColor whiteColor];
        if(self.delegate && [self.delegate respondsToSelector:@selector(onClick:)]){
            [self.delegate onClick: self.tag];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if(self.hasBottomLine){
        //画下划线
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithHexString:@"#8A8A8A"] setStroke];
        CGContextMoveToPoint(context, 50, self.bounds.size.height);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
        CGContextStrokePath(context);
    }
}



@end
