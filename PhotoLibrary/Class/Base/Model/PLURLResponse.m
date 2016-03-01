//
//  PLURLResponse.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "PLURLResponse.h"
#import <objc/runtime.h>

@implementation PLURLResponse

/**解析字典*/
- (void)parseResponseWithDictionary:(NSDictionary *)dic {//这个字典是数据请求时候返回的responseObject
    [self parseDataWithDictionary:dic inInstance:self];//self 为传进来的那个对象
}
/**解析.....这就是为什么从model中能够获取返回后的数据*/
- (void)parseDataWithDictionary:(NSDictionary *)dic inInstance:(id)instance {
    if (!dic || !instance) {
        return ;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSArray *properties = [NSObject propertiesOfClass:[instance class]];
    
    [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *propertyName = (NSString *)obj;
        
        id value = [dic objectForKey:propertyName];
        
        if ([value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSNumber class]]) {//属性为非集合
//            给模型的属性赋值
            [instance setValue:value forKey:propertyName];
            
        } else if ([value isKindOfClass:[NSDictionary class]]) {//属性为字典
            id property = [instance valueForKey:propertyName];
            Class subclass = [property class];
            if (!subclass) {
                NSString *classPropertyName = [propertyName stringByAppendingString:@"Class"];
                subclass = [instance valueForKey:classPropertyName];
            }
            id subinstance = [[subclass alloc] init];
            [instance setValue:subinstance forKey:propertyName];
            [self parseDataWithDictionary:(NSDictionary *)value inInstance:subinstance];
            
        } else if ([value isKindOfClass:[NSArray class]]) {//属性为数组
            Class subclass = [instance valueForKey:[propertyName stringByAppendingString:@"ElementClass"]];
            if (!subclass) {
                DLog(@"JSON Parsing Warning: cannot find element class of property: %@ in class: %@\n", propertyName, [[instance class] description])
                return;
            }
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [instance setValue:arr forKey:propertyName];
            
            for (NSDictionary *subDic in (NSArray *)value) {
                id subinstance = [[subclass alloc] init];
                [arr addObject:subinstance];
                [self parseDataWithDictionary:subDic inInstance:subinstance];
            }
        }
    }];
#pragma clang diagnostic pop
}

@end
