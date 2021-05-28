//
//  UILabel+Extension.m
//  smartwasp
//
//  Created by luotao on 2021/5/22.
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)

//设置文本icon
-(void) setDrawable: (UIImage*) icon{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    float lineHeight = [self intrinsicContentSize].height;
    NSTextAttachment *attach = [[NSTextAttachment alloc]init];
    attach.image = icon;
    attach.bounds = CGRectMake(0, (10 - lineHeight) / 2, 10, 10);
    NSAttributedString *picStr = [NSAttributedString attributedStringWithAttachment:attach];
    [str appendAttributedString:picStr];
    NSAttributedString *childStr2 = [[NSAttributedString alloc]initWithString:self.text];
    [str appendAttributedString:childStr2];
    self.attributedText = str;
}

@end
