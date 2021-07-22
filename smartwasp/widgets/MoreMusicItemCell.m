//
//  MoreMusicItemCell.m
//  smartwasp
//
//  Created by luotao on 2021/7/21.
//

#import "MoreMusicItemCell.h"
#import "UIImageView+WebCache.h"

@interface MoreMusicItemCell()
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleView;
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;

@end

@implementation MoreMusicItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setBean:(ItemBean *)bean{
    self.titleView.text = bean.name;
    self.subtitleView.text = [bean.from stringByReplacingOccurrencesOfString:@"内容来源" withString:@"版权所有"];
    [self.mImageView sd_setImageWithURL:[NSURL URLWithString:bean.image]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
