//
//  MusicItemCell.h
//  smartwasp
//
//  Created by luotao on 2021/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicItemCell : UITableViewCell

@property (nonatomic) NSInteger serial;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

@end

NS_ASSUME_NONNULL_END
