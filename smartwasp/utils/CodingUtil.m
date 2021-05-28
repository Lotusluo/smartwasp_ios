//
//  CodingUtil.m
//  smartwasp
//
//  Created by luotao on 2021/4/16.
//

#import "CodingUtil.h"

@implementation CodingUtil


+(NSString*) hexStringFromData:(NSData*) data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *string = @"";
    for (NSInteger i = 0; i<data.length; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i] & 0xff]; //16进制数
        newHexStr = [newHexStr uppercaseString];
        if ([newHexStr length] == 1) {
            newHexStr = [NSString stringWithFormat:@"0%@",newHexStr];
        }
        string = [string stringByAppendingString:newHexStr];
    }
    return string;
}


+(NSData*) dataFromHexString:(NSString*)string{
    const char *ch = [[string lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData data];
    while (*ch) {
        if (*ch == ' ') {
            continue;
        }
        char byte = 0;
        if ('0' <= *ch && *ch <= '9') {
            byte = *ch - '0';
        } else if ('a' <= *ch && *ch <= 'f') {
            byte = *ch - 'a' + 10;
        } else if ('A' <= *ch && *ch <= 'F') {
            byte = *ch - 'A' + 10;
        }
        ch++;
        byte = byte << 4;
        if (*ch) {
            if ('0' <= *ch && *ch <= '9') {
                byte += *ch - '0';
            } else if ('a' <= *ch && *ch <= 'f') {
                byte += *ch - 'a' + 10;
            } else if('A' <= *ch && *ch <= 'F') {
                byte += *ch - 'A' + 10;
            }
            ch++;
        }
        [data appendBytes:&byte length:1];
    }
    return data;
}

@end
