//
//  MoreMusicItemCell.m
//  smartwasp
//
//  Created by luotao on 2021/7/21.
//

#import "ABUITableViewCell.h"
#import "UIImageView+WebCache.h"

@interface ABUITableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleView;
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;

@end

@implementation ABUITableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//设置标题
-(void)setTitle:(NSString*)title{
    self.titleView.text = title;
}
//设置副标题
-(void)setSubtitle:(NSString*)subtitle{
    self.subtitleView.text = subtitle;
}
//设置图标
-(void)setIcon:(NSString*)path{
    [self.mImageView sd_setImageWithURL:[NSURL URLWithString:path]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
