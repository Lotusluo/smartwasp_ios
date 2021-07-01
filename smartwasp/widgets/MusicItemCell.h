//
//  MusicItemCell.h
//  smartwasp
//
//  Created by luotao on 2021/6/15.
//

#import <UIKit/UIKit.h>
#import "SongBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicItemCell : UITableViewCell


@property (nonatomic,strong)SongBean *song;
@property (nonatomic) NSInteger serial;
@property(nonatomic,strong) NSString *groupID;

@end

NS_ASSUME_NONNULL_END
