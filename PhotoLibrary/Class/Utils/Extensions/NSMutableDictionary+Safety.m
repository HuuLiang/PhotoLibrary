//
//  NSMutableDictionary+Safety.m
//  YuePaoBa
//
//  Created by Sean Yue on 15/12/11.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "NSMutableDictionary+Safety.h"

@implementation NSMutableDictionary (Safety)

- (void)safely_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)safely_setInteger:(NSInteger)integer forKey:(id<NSCopying>)aKey {
    if (integer != NSNotFound) {
        [self setObject:@(integer) forKey:aKey];
    }
}

- (NSInteger)safely_integerForKey:(id<NSCopying>)aKey {
    NSNumber *value = [self objectForKey:aKey];
    if (!value) {
        return NSNotFound;
    }
    
    return value.integerValue;
}
@end
