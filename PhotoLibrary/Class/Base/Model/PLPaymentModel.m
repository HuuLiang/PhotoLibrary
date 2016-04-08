//
//  PLPaymentModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLPaymentModel.h"
#import "NSDictionary+PLSign.h"

static const NSTimeInterval kRetryingTimeInterval = 180;

static NSString *const kSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

@interface PLPaymentModel ()
@property (nonatomic,retain) NSTimer *retryingTimer;
@end

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

/**给出参数，加密*/
- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    
    NSDictionary *signParams = @{  @"appId":PL_REST_APP_ID,
                                   @"key":kSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":[PLConfiguration sharedConfig].channelNo,
                                   @"pV":PL_REST_PV};
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];//返回的是加密后的字符串
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kPaymentEncryptionPassword excludeKeys:@[@"key"]];//转码加密..后的数据
    return @{@"data":encryptedDataString, @"appId":PL_REST_APP_ID};
}


/**下单时间*/
- (void)startRetryingToCommitUnprocessedOrders {
    if (!self.retryingTimer) {
        @weakify(self);
        self.retryingTimer = [NSTimer bk_scheduledTimerWithTimeInterval:kRetryingTimeInterval block:^(NSTimer *timer) {
            @strongify(self);
            DLog(@"Payment: on retrying to commit unprocessed orders!");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self commitUnprocessedOrders];//提交支付信息
            });
        } repeats:YES];
    }
}

- (void)stopRetryingToCommitUnprocessedOrders {
    [self.retryingTimer invalidate];
    self.retryingTimer = nil;
}
/**提交订单*/
- (void)commitUnprocessedOrders {
    NSArray<PLPaymentInfo *> *unprocessedPaymentInfos = [PLUtil paidNotProcessedPaymentInfos];
    [unprocessedPaymentInfos enumerateObjectsUsingBlock:^(PLPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self commitPaymentInfo:obj];//提交支付信息
    }];
}
#pragma mark - 提交支付信息接口
/**提交支付信息..返回是否成功*/
- (BOOL)commitPaymentInfo:(PLPaymentInfo *)paymentInfo {
    return [self commitPaymentInfo:paymentInfo withCompletionHandler:nil];
}
/**提交支付信息，返回是否提交成功*/
- (BOOL)commitPaymentInfo:(PLPaymentInfo *)paymentInfo withCompletionHandler:(PLPaidCompletionHandler)handler {
    
    NSDictionary *statusDic = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(0), @(PAYRESULT_ABANDON):@(2), @(PAYRESULT_UNKNOWN):@(0)};
    
    if (nil == [PLUtil userId] || paymentInfo.orderId.length == 0) {
        return NO;
    }
    //PLPaymentInfo支付信息
    NSDictionary *params = @{@"uuid":[PLUtil userId],
                             @"orderNo":paymentInfo.orderId,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":paymentInfo.orderPrice.stringValue,
                             @"channelNo":[PLConfiguration sharedConfig].channelNo,
                             @"contentId":paymentInfo.contentId.stringValue ?: @"0",
                             @"contentType":paymentInfo.contentType.stringValue ?: @"0",
                             @"pluginType":paymentInfo.paymentType,
                             @"payPointType":paymentInfo.payPointType ?: @"1",
                             @"appId":PL_REST_APP_ID,
                             @"versionNo":@([PLUtil appVersion]),
                             @"status":statusDic[paymentInfo.paymentResult],
                             @"pV":PL_REST_PV,
                             @"payTime":paymentInfo.paymentTime};   //支付参数
    
    BOOL success = [super requestURLPath:PL_PAYMENT_COMMIT_URL
                              withParams:params
                         responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        if (respStatus == PLURLResponseSuccess) {
                            paymentInfo.paymentStatus = @(PLPaymentStatusProcessed);
                            [paymentInfo save];//保存支付状态
                        } else {
                            DLog(@"Payment: fails to commit the order with orderId:%@", paymentInfo.orderId);
                        }
                        
                        if (handler) {//返回支付是否成功的状态
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
@end
