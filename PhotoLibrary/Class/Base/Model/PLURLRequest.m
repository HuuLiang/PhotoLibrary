//
//  PLURLRequest.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLURLRequest.h"
#import <AFNetworking.h>

@interface PLURLRequest ()
@property (nonatomic,retain) AFHTTPRequestOperationManager *requestOpManager;
@property (nonatomic,retain) AFHTTPRequestOperation *requestOp;

@property (nonatomic,retain) AFHTTPRequestOperationManager *standbyRequestOpManager;
@property (nonatomic,retain) AFHTTPRequestOperation *standbyRequestOp;

-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(NSDictionary *)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(PLURLResponseHandler)responseHandler;
@end

@implementation PLURLRequest

+ (Class)responseClass {
    return [PLURLResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return NO;
}

+ (NSString *)persistenceFilePath {
    NSString *fileName = NSStringFromClass([self responseClass]);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.plist", [NSBundle mainBundle].resourcePath, fileName];
    return filePath;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([[[self class] responseClass] isSubclassOfClass:[PLURLResponse class]]) {
            NSDictionary *lastResponse = [NSDictionary dictionaryWithContentsOfFile:[[self class] persistenceFilePath]];
            if (lastResponse) {
                PLURLResponse *urlResponse = [[[[self class] responseClass] alloc] init];
                [urlResponse parseResponseWithDictionary:lastResponse];
                self.response = urlResponse;
            }
        }
        
    }
    return self;
}

- (NSURL *)baseURL {
    return [NSURL URLWithString:PL_BASE_URL];
}

- (NSURL *)standbyBaseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return YES;
}

- (PLURLRequestMethod)requestMethod {
    return PLURLGetRequest;
}

-(AFHTTPRequestOperationManager *)requestOpManager {
    if (_requestOpManager) {
        return _requestOpManager;
    }
    
    _requestOpManager = [[AFHTTPRequestOperationManager alloc]
                         initWithBaseURL:[self baseURL]];
    return _requestOpManager;
}

- (AFHTTPRequestOperationManager *)standbyRequestOpManager {
    if (_standbyRequestOpManager) {
        return _standbyRequestOpManager;
    }
    
    _standbyRequestOpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[self standbyBaseURL]];
    return _standbyRequestOpManager;
}

#pragma mark - 数据请求基于AFN封装的部分
-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(NSDictionary *)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(PLURLResponseHandler)responseHandler
{
    if (urlPath.length == 0) {
        if (responseHandler) {
            responseHandler(PLURLResponseFailedByParameter, nil);
        }
        return NO;
    }
    
    DLog(@"Requesting %@ !\nwith parameters: %@\n", urlPath, params);
    
    @weakify(self);
    self.response = [[[[self class] responseClass] alloc] init];//初始化response，一般这里是....model进来
    
//========待激活的代码块区==由AFN中激活success/failure==================
    void (^success)(AFHTTPRequestOperation *,id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        
        DLog(@"Response for %@ : %@\n", urlPath, responseObject);
        [self processResponseObject:responseObject withResponseHandler:responseHandler];
    };
    
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error for %@ : %@\n", urlPath, error.localizedDescription);
        
        if (shouldNotifyError) {
            if ([self shouldPostErrorNotification]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                                    object:self
                                                                  userInfo:@{kNetworkErrorCodeKey:@(PLURLResponseFailedByNetwork),
                                                                             kNetworkErrorMessageKey:error.localizedDescription}];
            }
        }
        
        if (responseHandler) {
            responseHandler(PLURLResponseFailedByNetwork,error.localizedDescription);
        }
    };
//==============================================================
    AFHTTPRequestOperation *requestOp;
    if (self.requestMethod == PLURLGetRequest) {
        requestOp = [isStandBy?self.standbyRequestOpManager:self.requestOpManager GET:urlPath parameters:params success:success failure:failure];
    } else {
        requestOp = [isStandBy?self.standbyRequestOpManager:self.requestOpManager POST:urlPath parameters:params success:success failure:failure];
    }
    
    if (isStandBy) {
        self.standbyRequestOp = requestOp;
    } else {
        self.requestOp = requestOp;
    }
    return YES;
}

- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(PLURLResponseHandler)responseHandler {
    BOOL useStandbyRequest = standbyUrlPath.length > 0;
    BOOL success = [self requestURLPath:urlPath
                             withParams:params
                              isStandby:NO
                      shouldNotifyError:!useStandbyRequest
                        responseHandler:^(PLURLResponseStatus respStatus, NSString *errorMessage)
    {
        if (useStandbyRequest && respStatus == PLURLResponseFailedByNetwork) {
            [self requestURLPath:standbyUrlPath withParams:params isStandby:YES shouldNotifyError:YES responseHandler:responseHandler];
        } else {
            if (responseHandler) {
                responseHandler(respStatus,errorMessage);
            }
        }
    }];
    return success;
}

-(BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(PLURLResponseHandler)responseHandler
{
    return [self requestURLPath:urlPath standbyURLPath:nil withParams:params responseHandler:responseHandler];
}
/**处理返回对像*/
- (void)processResponseObject:(id)responseObject withResponseHandler:(PLURLResponseHandler)responseHandler {
    PLURLResponseStatus status = PLURLResponseNone;
    NSString *errorMessage;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if ([self.response isKindOfClass:[PLURLResponse class]]) {
            PLURLResponse *urlResp = self.response;
            [urlResp parseResponseWithDictionary:responseObject];//数据解析
            /**PLURLResponse的返回的属性
             @property (nonatomic) NSNumber *success;
             @property (nonatomic) NSString *resultCode;
              */
            status = urlResp.success.boolValue ? PLURLResponseSuccess : PLURLResponseFailedByInterface;
            errorMessage = (status == PLURLResponseSuccess) ? nil : [NSString stringWithFormat:@"ResultCode: %@", urlResp.resultCode];
        } else {
            status = PLURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON dictionary.\n";
        }
        
        if ([[self class] shouldPersistURLResponse]) {
            NSString *filePath = [[self class] persistenceFilePath];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (![((NSDictionary *)responseObject) writeToFile:filePath atomically:YES]) {
                    DLog(@"Persist response object fails!");
                }
            });
        }
    } else if ([responseObject isKindOfClass:[NSString class]]) {
        if ([self.response isKindOfClass:[NSString class]]) {
            self.response = responseObject;
            status = PLURLResponseSuccess;
        } else {
            status = PLURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON string.\n";
        }
    } else {
        errorMessage = @"Error data structure of response from interface!\n";
        status = PLURLResponseFailedByInterface;
    }
    
    if (status != PLURLResponseSuccess) {
        DLog(@"Error message : %@\n", errorMessage);
        
        if ([self shouldPostErrorNotification]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                                object:self
                                                              userInfo:@{kNetworkErrorCodeKey:@(status),
                                                                         kNetworkErrorMessageKey:errorMessage}];
        }
    }
    
    if (responseHandler) {
        responseHandler(status, errorMessage);
    }

}
@end
