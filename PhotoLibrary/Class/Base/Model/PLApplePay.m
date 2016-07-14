//
//  PLApplePay.m
//  PhotoLibrary
//
//  Created by ylz on 16/7/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLApplePay.h"
#import "PLPaymentConfig.h"

@interface PLApplePay ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (nonatomic) NSMutableArray *priceArray;

@end

@implementation PLApplePay

+ (instancetype)shareApplePay {
    static PLApplePay *_applePay;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _applePay = [[PLApplePay alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_applePay];
    });
    return _applePay;
}

- (void)getProdructionInfo {
    DLog(@"请求商品信息");
    SKProductsRequest *productReq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[@"VIDEO_VIP",@"PICTURE_VIP"]]];
    productReq.delegate = self;
    [productReq start];
}

- (void)payWithProductionId:(NSString *)proId {
    SKMutablePayment *aPayment = [[SKMutablePayment alloc] init];
    aPayment.productIdentifier = proId;
    [[SKPaymentQueue defaultQueue] addPayment:aPayment];
}
/**
 *  获取商品信息
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    _priceArray = [[NSMutableArray alloc] init];
    DLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    DLog(@"-------------myProduct-----------------%lu",(unsigned long)myProduct.count);
    DLog(@"无效产品Product ID:%@",response.invalidProductIdentifiers);
    DLog(@"产品付费数量: %d", (int)[myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        DLog(@"--------------------");
        DLog(@"product info");
        DLog(@"SKProduct 描述信息%@", [product description]);
        DLog(@"产品标题 %@" , product.localizedTitle);
        DLog(@"产品描述信息: %@" , product.localizedDescription);
        DLog(@"价格: %@" , product.price);
        DLog(@"Product id: %@" , product.productIdentifier);
        [_priceArray addObject:product.price];
    }
    
    [self setPriceInfoWithArray:_priceArray];
    
}
- (void)setPriceInfoWithArray:(NSArray *)array {
    if (array.count == 0) {
        return;
    }
    [PLPaymentConfig sharedConfig].vipPointInfo = [NSString stringWithFormat:@"%ld:1|%ld:3",[_priceArray[0] integerValue]*100,[_priceArray[1] integerValue]*100];
    DLog("-----vipInfo-%@---",[PLPaymentConfig sharedConfig].vipPointInfo);
    _isGettingPriceInfo = NO;
}
//获取支付结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"pay out:%ld  id:%@",(long)transaction.transactionState,transaction.payment.productIdentifier);
        /*
         SKPaymentTransactionStatePurchasing,    // Transaction is being added to the server queue.
         SKPaymentTransactionStatePurchased,     // Transaction is in queue, user has been charged.  Client should complete the transaction.
         SKPaymentTransactionStateFailed,        // Transaction was cancelled or failed before being added to the server queue.
         SKPaymentTransactionStateRestored,      // Transaction was restored from user's purchase history.  Client should complete the transaction.
         SKPaymentTransactionStateDeferred*/
        NSLog(@"%@",transaction.transactionIdentifier);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"正在购买中");
                break;
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"购买完成");
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                //验证字符串,如果是8.0以上的系统，通过新的方式获取到receiptData
                NSData * receiptData;
                NSString * version=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
                if (version.intValue>=8)
                {
                    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
                    receiptData = [NSData dataWithContentsOfURL:receiptUrl];
                }
                else
                {
                    receiptData = transaction.transactionReceipt;
                }
                NSString * base64Str=[self encode:receiptData.bytes length:receiptData.length];
                DLog("-----------base64Str------: %@",base64Str);
                
                /**
                 *  验证成功之后向自己的服务器提交结果
                 */
//                [self sendInfoToServer:transaction.payment.productIdentifier];
//                [self.delegate sendPaymentState:transaction.transactionState];
            }
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"购买失败");
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
//                [self.delegate sendPaymentState:transaction.transactionState];
                break;
                
            default:
                break;
        }
        
    }
}

-(NSString *)encode:(const uint8_t *)input length:(NSInteger)length
{
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    for (NSInteger i = 0; i < length; i += 3)
    {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++)
        {
            value <<= 8;
            if (j < length)
            {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}
@end
