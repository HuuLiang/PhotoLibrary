//
//  PLUserAccessModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/11/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"

typedef void (^PLUserAccessCompletionHandler)(BOOL success);

@interface PLUserAccessModel : PLEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)requestUserAccess;

@end
