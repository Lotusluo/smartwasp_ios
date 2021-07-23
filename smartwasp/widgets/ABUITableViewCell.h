//
//  MoreMusicItemCell.h
//  smartwasp
//
//  Created by luotao on 2021/7/21.
//

#import <UIKit/UIKit.h>
#import "ItemBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface ABUITableViewCell : UITableViewCell

//设置标题
-(void)setTitle:(NSString*)title;
//设置副标题
-(void)setSubtitle:(NSString*)subtitle;
//设置图标
-(void)setIcon:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
