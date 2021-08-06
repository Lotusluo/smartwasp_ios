//
//  NSString+Extension.m
//  smartwasp
//
//  Created by luotao on 2021/8/6.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

-(BOOL)isEmpty{
    return NULL == self || [self isEqualToString:@""];
}

@end
