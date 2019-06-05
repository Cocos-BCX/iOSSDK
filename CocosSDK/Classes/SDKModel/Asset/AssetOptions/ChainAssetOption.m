//
//  ChainAssetOption.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainAssetOption.h"
#import "NSObject+DataToObject.h"

#import "CocosPackData.h"

#import "ChainPrice.h"
#import "ChainObjectId.h"

@implementation ChainAssetOption

- (instancetype)init
{
    self = [super init];
    if (self) {
        _whitelist_authorities = @[];
        _blacklist_authorities = @[];
        _whitelist_markets = @[];
        _blacklist_markets = @[];
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
    
    
    
    if ([key isEqualToString:@"max_supply"]) {
        _max_supply = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",value]];
        return;
    }
    
    if ([key isEqualToString:@"description"]) {
        _descriptions = value;
        return;
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        if (![key isEqualToString:@"extensions"]) {
            [super setValue:[ChainObjectId generateFromDataArray:value] forKey:key];
            return;
        }else {
            [super setValue:value forKey:key];
            return;
        }
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
    NSMutableDictionary *dic = [[self defaultGetDictionary] mutableCopy];
    
    dic[@"description"] = dic[@"descriptions"];
    
    dic[@"descriptions"] = nil;
    
    return dic;
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:100];
    
    [data appendData:[CocosPackData packLongValue:_max_supply.longValue]];
    
    [data appendData:[CocosPackData packShort:_market_fee_percent]];
    
    [data appendData:[CocosPackData packLongValue:_max_market_fee]];
    
    [data appendData:_issuer_permissions.transformToData];
    
    [data appendData:_flags.transformToData];
    
    [data appendData:_core_exchange_rate.transformToData];
    
    [self packArray:self.whitelist_authorities toData:data];
    
    [self packArray:self.blacklist_authorities toData:data];
    
    [self packArray:self.whitelist_markets toData:data];
    
    [self packArray:self.blacklist_markets toData:data];
    
    [data appendData:[CocosPackData packString:self.descriptions]];
    
    [data appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return data.copy;
}

- (void)packArray:(NSArray <id <ObjectToDataProtocol>>*)array toData:(NSMutableData *)data {
    [data appendData:[CocosPackData packUnsigedInteger:array.count]];
    
    for (id <ObjectToDataProtocol>obj in array) {
        [data appendData:obj.transformToData];
    }
}

@end
