//
//  PLURLRequest.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLURLResponse.h"

typedef NS_ENUM(NSUInteger, PLURLResponseStatus) {
    PLURLResponseSuccess,
    PLURLResponseFailedByInterface,
    PLURLResponseFailedByNetwork,
    PLURLResponseFailedByParsing,
    PLURLResponseFailedByParameter,
    PLURLResponseNone
};

typedef NS_ENUM(NSUInteger, PLURLRequestMethod) {
    PLURLGetRequest,
    PLURLPostRequest
};
typedef void (^PLURLResponseHandler)(PLURLResponseStatus respStatus, NSString *errorMessage);

@interface PLURLRequest : NSObject

@property (nonatomic,retain) id response;

+ (Class)responseClass;  // override this method to provide a custom class to be used when instantiating instances of PLURLResponse
+ (BOOL)shouldPersistURLResponse;
- (NSURL *)baseURL; // override this method to provide a custom base URL to be used
- (NSURL *)standbyBaseURL; // override this method to provide a custom standby base URL to be used

- (BOOL)shouldPostErrorNotification;
- (PLURLRequestMethod)requestMethod;

/**数据请求接口.1*/
- (BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(PLURLResponseHandler)responseHandler;
/**数据请求接口.2*/
- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(PLURLResponseHandler)responseHandler;

// For subclass pre/post processing response object
- (void)processResponseObject:(id)responseObject withResponseHandler:(PLURLResponseHandler)responseHandler;

@end
