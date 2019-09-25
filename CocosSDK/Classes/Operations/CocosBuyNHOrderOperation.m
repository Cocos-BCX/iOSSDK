//
//  CocosBuyNHOrderOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/4/24.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "CocosBuyNHOrderOperation.h"
#import "ChainObjectId.h"
#import "ChainAssetAmountObject.h"
#import "CocosPackData.h"

@implementation CocosBuyNHOrderOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _extensions = @[];
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
    if ([key isEqualToString:@"order"]) {
        self.order = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"fee_paying_account"]) {
        self.fee_paying_account = [ChainObjectId generateFromObject:value];
        return;
    }
    
    if ([key isEqualToString:@"seller"]) {
        self.seller = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"nh_asset"]) {
        self.nh_asset = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"price_asset_id"]) {
        self.price_asset_id = [ChainObjectId generateFromObject:value];
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:6];
    
//    dic[@"fee"] = [self.fee generateToTransferObject];
    
    dic[@"order"] = [self.order generateToTransferObject];
    
    dic[@"fee_paying_account"] = [self.fee_paying_account generateToTransferObject];
    
    dic[@"seller"] = [self.seller generateToTransferObject];
    
    dic[@"nh_asset"] = [self.nh_asset generateToTransferObject];
    
    dic[@"price_amount"] = self.price_amount;
    
    dic[@"price_asset_id"] = [self.price_asset_id generateToTransferObject];
    
    dic[@"price_asset_symbol"] = self.price_asset_symbol;
    
    dic[@"extensions"] = self.extensions;
    
    return [dic copy];
}

- (NSData *)transformToData {
    NSMutableData *mutableData = [NSMutableData dataWithCapacity:300];
    
//    if (!self.fee) {
//        [mutableData appendData:[[[ChainAssetAmountObject alloc] initFromAssetId:[ChainObjectId generateFromObject:@"1.3.0"] amount:0] transformToData]];
//    }else {
//        [mutableData appendData:[self.fee transformToData]];
//    }
    
    [mutableData appendData:[self.order transformToData]];
    
    [mutableData appendData:[self.fee_paying_account transformToData]];
    
    [mutableData appendData:[self.seller transformToData]];
    
    [mutableData appendData:[self.nh_asset transformToData]];
    
    NSData *priceAmountData = [CocosPackData packString:self.price_amount];
    [mutableData appendData:priceAmountData];
    
    [mutableData appendData:[self.price_asset_id transformToData]];
    
    NSData *priceAssetSymbolData = [CocosPackData packString:self.price_asset_symbol];
    [mutableData appendData:priceAssetSymbolData];
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}

@end
