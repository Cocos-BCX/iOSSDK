//
//  ChainContract.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/4/16.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "ChainContract.h"
#import "NSObject+DataToObject.h"

@implementation ChainContract

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    if ([key isEqualToString:@"id"]) {
        key = @"identifier";
    }
    
    value = [self defaultGetValue:value forKey:key];
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

+ (instancetype)generateFromObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;
    
    return [[self alloc] initWithDic:object];
}

- (id)generateToTransferObject {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self defaultGetDictionary]];
    
    dictionary[@"id"] = dictionary[@"identifier"];
    
    dictionary[@"identifier"] = nil;
    
    return [dictionary copy];
}
@end
