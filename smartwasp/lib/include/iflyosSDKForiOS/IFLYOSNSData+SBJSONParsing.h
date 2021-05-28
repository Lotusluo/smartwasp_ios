//
//  IFLYOSNSData+SBJSONParsing.h
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (IFLYOSNSData_SBJSONParsing)
-(NSDictionary *) JSONDataWithDictionary;
-(NSArray *) JSONDataWithArray;
-(NSString *) JSONDataWithString;
@end
