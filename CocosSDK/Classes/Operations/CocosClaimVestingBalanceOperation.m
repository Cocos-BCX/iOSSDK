//
//  CocosClaimVestingBalanceOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/9/26.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosClaimVestingBalanceOperation.h"
#import "ChainObjectId.h"
#import "CocosPackData.h"
#import "ChainAssetAmountObject.h"
#import "NSObject+DataToObject.h"

@implementation CocosClaimVestingBalanceOperation

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
    
    
    if ([key isEqualToString:@"vesting_balance"]) {
        self.vesting_balance = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"owner"]) {
        self.owner = [ChainObjectId generateFromObject:value];
        return;
    }
    
    if ([key isEqualToString:@"amount"]) {
        self.amount = [ChainAssetAmountObject generateFromObject:value];
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

//
- (id)generateToTransferObject {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self defaultGetDictionary]];
    
    return [dic copy];
}

- (NSData *)transformToData {
    NSMutableData *mutableData = [NSMutableData dataWithCapacity:300];
    
    [mutableData appendData:[self.vesting_balance transformToData]];
    
    [mutableData appendData:[self.owner transformToData]];
    
    [mutableData appendData:[self.amount transformToData]];
    
    return [mutableData copy];
}
@end
