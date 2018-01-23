//
//  NSMutableDictionary+Safety.h
//  YuePaoBa
//
//  Created by Sean Yue on 15/12/11.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safety)

- (void)safely_setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)safely_setInteger:(NSInteger)integer forKey:(id<NSCopying>)aKey;

- (NSInteger)safely_integerForKey:(id<NSCopying>)aKey;
@end
