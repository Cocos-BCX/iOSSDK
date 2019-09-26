//
//  CocosMortgageGasOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/9/25.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosMortgageGasOperation.h"
#import "ChainObjectId.h"
#import "CocosPackData.h"
#import "NSObject+DataToObject.h"

@implementation CocosMortgageGasOperation

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
    if ([key isEqualToString:@"mortgager"]) {
        self.mortgager = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"beneficiary"]) {
        self.beneficiary = [ChainObjectId generateFromObject:value];
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
    
    [mutableData appendData:[self.mortgager transformToData]];
    
    [mutableData appendData:[self.beneficiary transformToData]];
    
    NSData *collateralData = [CocosPackData packLongValue:self.collateral];
    [mutableData appendData:collateralData];
    
    return [mutableData copy];
}
@end
