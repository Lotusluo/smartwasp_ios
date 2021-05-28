//
//  IFLYOSWKWebView+IFLYOSWebView.h
//  iflyosSDK
//
//  Created by admin on 2018/8/27.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView(IFLYOSWKWebView_IFLYOSWebView)
-(void) loadCustomRequest:(NSURLRequest *) request;
@end
