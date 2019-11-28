//
//  CocosCallContractOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/3/28.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "CocosCallContractOperation.h"
#import "ChainAssetAmountObject.h"
#import "ChainObjectId.h"
#import "CocosPackData.h"
#import "NSData+HashData.h"
#import "ChainAssetObject.h"
#import "NSObject+DataToObject.h"

@implementation CocosCallContractOperation

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
    if ([key isEqualToString:@"caller"]) {
        self.caller = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"contract_id"]) {
        self.contract_id = [ChainObjectId generateFromObject:value];
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
    
//    if (!self.fee) {
//        [mutableData appendData:[[[ChainAssetAmountObject alloc] initFromAssetId:[ChainObjectId generateFromObject:@"1.3.0"] amount:0] transformToData]];
//    }else {
//        [mutableData appendData:[self.fee transformToData]];
//    }
    
    [mutableData appendData:[self.caller transformToData]];
    
    [mutableData appendData:[self.contract_id transformToData]];
    
    NSData *funcnameData = [CocosPackData packString:self.function_name];
    [mutableData appendData:funcnameData];
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.value_list.count]];
    for (NSArray *arr_value in self.value_list) {
        [mutableData appendData:[CocosPackData packUnsigedInteger:[arr_value.firstObject integerValue]]];
        NSDictionary *baseValueDic = arr_value.lastObject;
        NSString *baseValue = baseValueDic[@"v"];
        //        NSData *baseValueData = [CocosPackData packString:baseValue];
        NSData *baseValueData = [CocosPackData packString:[NSString stringWithFormat:@"%@",baseValue]];
        [mutableData appendData:baseValueData];
    }
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}
@end
