//
//  CocosDeleteNHOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/7/8.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosDeleteNHOperation.h"
#import "ChainAssetAmountObject.h"
#import "NSObject+DataToObject.h"
#import "ChainObjectId.h"
#import "CocosPackData.h"

@implementation CocosDeleteNHOperation
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
//    if ([key isEqualToString:@"fee"]) {
//        self.fee = [ChainAssetAmountObject generateFromObject:value];
//        return;
//    }
    if ([key isEqualToString:@"fee_paying_account"]) {
        self.fee_paying_account = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"nh_asset"]) {
        self.nh_asset = [ChainObjectId generateFromObject:value];
        return;
    }
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

- (NSData *)transformToData {
    NSMutableData *mutableData = [NSMutableData dataWithCapacity:300];
    
//    if (!self.fee) {
//        [mutableData appendData:[[[ChainAssetAmountObject alloc] initFromAssetId:[ChainObjectId generateFromObject:@"1.3.0"] amount:0] transformToData]];
//    }else {
//        [mutableData appendData:[self.fee transformToData]];
//    }
    [mutableData appendData:[self.fee_paying_account transformToData]];

    [mutableData appendData:[self.nh_asset transformToData]];
    
    return [mutableData copy];
}

@end
