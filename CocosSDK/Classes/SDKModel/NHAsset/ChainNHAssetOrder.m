//
//  ChainNHAssetOrder.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/4/24.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "ChainNHAssetOrder.h"
#import "ChainObjectId.h"
#import "ChainAssetAmountObject.h"
#import "NSObject+DataToObject.h"

@implementation ChainNHAssetOrder

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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self defaultGetDictionary]];
    
    dic[@"id"] =dic[@"identifier"];
    
    dic[@"identifier"] = nil;
    
    return [dic copy];
}
@end
