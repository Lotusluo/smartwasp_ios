//
//  ISWDelegate.h
//  smartwasp
//
//  Created by luotao on 2021/5/31.
//

#ifndef ISWDelegate_h
#define ISWDelegate_h

#import <Foundation/Foundation.h>

@protocol ISWClickDelegate<NSObject>
@required
-(void) onClick:(NSInteger)tag;
@optional
-(void)onConfirmClick;
-(void)onCancelClick;
@end


#endif /* ISWDelegate_h */
