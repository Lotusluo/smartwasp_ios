//
//  UILabel+Extension.m
//  smartwasp
//
//  Created by luotao on 2021/5/22.
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)

//设置文本icon
-(void)setLeftSquareDrawable:(UIImage*)icon{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    CGFloat lineHeight = [self intrinsicContentSize].height;
    CGFloat imageFixed = lineHeight * 2 / 3;
 
    NSTextAttachment *image = [[NSTextAttachment alloc]init];
    image.image = icon;
    image.bounds = CGRectMake(0, -1, imageFixed, imageFixed);
    NSAttributedString *imageWrapper = [NSAttributedString attributedStringWithAttachment:image];
    [str appendAttributedString:imageWrapper];
    
    NSAttributedString *text = [[NSAttributedString alloc]initWithString:self.text];
    [str appendAttributedString:text];
    self.attributedText = str;
}

@end
