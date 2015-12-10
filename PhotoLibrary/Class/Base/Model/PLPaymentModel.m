//
//  PLPaymentModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLPaymentModel.h"
#import "NSDictionary+PLSign.h"
#import "AlipayManager.h"

static NSString *const kSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

@implementation PLPaymentModel

+ (instancetype)sharedModel {
    static PLPaymentModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[PLPaymentModel alloc] init];
    });
    return _sharedModel;
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (PLURLRequestMethod)requestMethod {
    return PLURLPostRequest;
}

+ (NSString *)signKey {
    return kSignKey;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":[PLUtil appId],
                                   @"key":kSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":[PLConfig sharedConfig].channelNo,
                                   @"pV":@(1) };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":[PLUtil appId]};
}

- (BOOL)paidWithOrderId:(NSString *)orderId
                  price:(NSNumber *)price
                 result:(NSInteger)result
              contentId:(NSString *)contentId
            contentType:(NSString *)contentType
           payPointType:(NSString *)payPointType
            paymentType:(PLPaymentType)paymentType
      completionHandler:(PLPaidCompletionHandler)handler {
    NSDictionary *statusDic = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(0), @(PAYRESULT_ABANDON):@(2)};
    
    if (nil == [PLUtil userId] || orderId.length == 0 || contentId == nil || contentType == nil) {
        return NO;
    }
    
    NSDictionary *params = @{@"uuid":[PLUtil userId],
                             @"orderNo":orderId,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":price,
                             @"channelNo":[PLConfig sharedConfig].channelNo,
                             @"contentId":contentId,
                             @"contentType":contentType,
                             @"pluginType":@(paymentType),
                             @"payPointType":@(payPointType.integerValue),
                             @"appId":[PLUtil appId],
                             @"versionNo":@([PLUtil appVersion].integerValue),
                             @"status":statusDic[@(result)],
                             @"pV":@(1) };
    
    BOOL success = [super requestURLPath:[PLConfig sharedConfig].paymentURLPath withParams:params responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage) {
        if (handler) {
            handler(respStatus == PLURLResponseSuccess);
        }
    }];
    return success;
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(PLURLResponseHandler)responseHandler {
    NSDictionary *decryptedResponse = [self decryptResponse:responseObject];
    DLog(@"Payment response : %@", decryptedResponse);
    NSNumber *respCode = decryptedResponse[@"response_code"];
    PLURLResponseStatus status = (respCode.unsignedIntegerValue == 100) ? PLURLResponseSuccess : PLURLResponseFailedByInterface;
    if (responseHandler) {
        responseHandler(status, nil);
    }
}

- (BOOL)processPendingOrder {
    NSArray *order = [PLUtil orderForSavePending];
    if (order.count == PLPendingOrderItemCount) {
        return [self paidWithOrderId:order[PLPendingOrderId]
                               price:order[PLPendingOrderPrice]
                              result:PAYRESULT_SUCCESS
                           contentId:order[PLPendingOrderProgramId]
                         contentType:order[PLPendingOrderProgramType]
                        payPointType:order[PLPendingOrderPayPointType]
                         paymentType:((NSNumber *)order[PLPendingOrderPaymentType]).unsignedIntegerValue
                   completionHandler:nil];
    }
    return NO;
}
@end
