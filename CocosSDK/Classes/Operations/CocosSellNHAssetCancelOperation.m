//
//  CocosSellNHAssetCancelOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/7/9.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosSellNHAssetCancelOperation.h"
#import "ChainObjectId.h"
#import "ChainAssetAmountObject.h"
#import "CocosPackData.h"

@implementation CocosSellNHAssetCancelOperation

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
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}
@end
