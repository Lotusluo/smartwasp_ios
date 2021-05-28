//
//  IFLYOSProductManager.h
//  iflyosSDKForiOS
//
//  Created by 周经伟 on 2019/7/16.
//  Copyright © 2019 iflyosSDKForiOS. All rights reserved.
//  IAP支付

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFLYOSProductManager : NSObject
/**
 *  支付接口(同步)
 *  tradeNo : 订单号
 *  productId : 产品ID
 *  deviceId : 设备ID
 */
-(NSDictionary *) synPay:(NSString *) tradeNo
               productId:(NSString *) productId
                deviceId:(NSString *) deviceId;

/**
 *  校验订单是否合法(同步)
 *  deviceId:设备ID
 *  tradeNo:订单ID
 *  receiptData:交易凭证的receipt-data(进行base64编码)
 */
-(NSDictionary *) synVerifyReceipt:(NSString *) deviceId
                           tradeNo:(NSString *) tradeNo
                       receiptData:(NSString *) receiptData;

@end

NS_ASSUME_NONNULL_END
