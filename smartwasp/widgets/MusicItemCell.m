//
//  MusicItemCell.m
//  smartwasp
//
//  Created by luotao on 2021/6/15.
//

#import "MusicItemCell.h"

@interface MusicItemCell()

@property (weak, nonatomic) IBOutlet UILabel *labelSerial;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageMore;

@end

@implementation MusicItemCell

-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *click=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSheetTap:)];
    [self.imageMore addGestureRecognizer:click];
}

- (IBAction)onSheetTap:(id)sender {
    NSLog(@"onTap");
}

-(void)setSerial:(NSInteger)serial{
    if(self.labelSerial){
        self.labelSerial.text = [NSString stringWithFormat:@"%ld",serial];
    }
}

-(void)setTitle:(NSString *)title{
    if(self.labelTitle){
        self.labelTitle.text = title;
    }
}

-(void)setSubtitle:(NSString *)subtitle{
    if(!subtitle || [subtitle isEqualToString:@""]){
        subtitle = @"-";
    }
    if(self.labelSubtitle){
        self.labelSubtitle.text = subtitle;
    }
}

@end
