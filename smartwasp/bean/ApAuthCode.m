//
//  ApAuthCode.m
//  smartwasp
//
//  Created by luotao on 2021/6/29.
//

#import "ApAuthCode.h"

@implementation ApAuthCode

-(BOOL)isOverdue{
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    return (self.created_at_local + self.expires_in - 150) < timestamp;
}

@end
