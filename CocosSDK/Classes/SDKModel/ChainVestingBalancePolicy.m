//
//  ChainVestingBalancePolicy.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/9/26.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "ChainVestingBalancePolicy.h"
#import "NSObject+DataToObject.h"

@implementation ChainVestingBalancePolicy

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self defaultGetDictionary]];
    
    return [dic copy];
}


@end
