//
//  PLActivateModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLEncryptedURLRequest.h"

typedef void (^PLActivateHandler)(BOOL success, NSString *userId);

@interface PLActivateModel : PLEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)activateWithCompletionHandler:(PLActivateHandler)handler;

@end
