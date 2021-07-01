//
//  MusicItemCell.m
//  smartwasp
//
//  Created by luotao on 2021/6/15.
//

#import "MusicItemCell.h"
#import "AppDialog.h"
#import <Masonry.h>
#import "UIViewHelper.h"
#import "IFLYOSSDK.h"
#import "Loading.h"
#import "iToast.h"
#import "AppDelegate.h"

#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface MusicItemCell()

@property (weak, nonatomic) IBOutlet UILabel *labelSerial;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) AppDialog *temp;

@end

@implementation MusicItemCell

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (IBAction)onSheetTap:(id)sender {
    AppDialog *dialog = [AppDialog createDialog:@"SongsPlayDialog" heightParam:150];
    [dialog show];
    UIView *view = dialog.baseView;
    //设置标题
    [UIViewHelper attachText:self.labelTitle.text widget:[view viewWithTag:10]];
    //设置播放点击
    UIButton *playBtn = [view viewWithTag:9];
    [playBtn addTarget:self action:@selector(onPlay) forControlEvents:UIControlEventTouchUpInside];
    self.temp = dialog;
}

//播放
-(void)onPlay{
    if(self.temp){
        [self.temp dismiss];
        self.temp = nil;
    }
    [Loading show:nil];
    if(self.groupID){
        [[IFLYOSSDK shareInstance] musicControlPlayGroup:APPDELEGATE.curDevice.device_id groupId:self.groupID mediaId:self.song._id statusCode:^(NSInteger code) {
            [Loading dismiss];
        } requestSuccess:^(id _Nonnull data) {
            [[iToast makeText:[NSString stringWithFormat:@"正在播放:%@",self.song.name]] show];
        } requestFail:^(id _Nonnull data) {
            [[iToast makeText:@"请开通音乐权限或重试!"] show];
        }];
    }else{
        [[IFLYOSSDK shareInstance] musicControlPlay:APPDELEGATE.curDevice.device_id mediaId:self.song._id sourceType:self.song.source_type statusCode:^(NSInteger code) {
            [Loading dismiss];
        } requestSuccess:^(id _Nonnull data) {
            [[iToast makeText:[NSString stringWithFormat:@"正在播放:%@",self.song.name]] show];
        } requestFail:^(id _Nonnull data) {
            [[iToast makeText:@"请开通音乐权限或重试!"] show];
        }];
    }
}

//设置播放源
-(void)setSong:(SongBean *)song{
    _song = song;
    if(self.labelTitle){
        self.labelTitle.text = song.name;
    }
    if(!song.artist || [song.artist isEqualToString:@""]){
        [self.labelTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
        }];
    }
    if(self.labelSubtitle){
        self.labelSubtitle.text = song.artist;
    }
}

-(void)setSerial:(NSInteger)serial{
    if(self.labelSerial){
        self.labelSerial.text = [NSString stringWithFormat:@"%ld",serial];
        [self updatePlayStatus:APPDELEGATE.mediaStatus ? APPDELEGATE.mediaStatus.data : nil];
    }
}

//跟新播放状态
-(void)updatePlayStatus:(MusicStateBean* __nullable) musicStateBean{
    self.labelSerial.textColor = [UIColor darkGrayColor];
    self.labelTitle.textColor = self.labelSerial.textColor;
    if(!musicStateBean || !musicStateBean.music){
        return;
    }
    self.labelSerial.textColor = [musicStateBean.music._id isEqualToString:self.song._id] ?
    [UIColor orangeColor] : [UIColor darkGrayColor];
    self.labelTitle.textColor = self.labelSerial.textColor;
}


@end
