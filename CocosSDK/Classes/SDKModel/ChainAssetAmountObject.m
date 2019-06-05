//
//  ChainAssetAmountObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainAssetAmountObject.h"
#import "ChainObjectId.h"
#import "CocosPackData.h"
@implementation ChainAssetAmountObject

- (instancetype)initFromAssetId:(ChainObjectId *)objectId amount:(long)amount {
    if (self = [super init]) {
        _assetId = objectId;
        _amount = amount;
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    if ([key isEqualToString:@"asset_id"]) {
        _assetId = [ChainObjectId generateFromObject:value];
        return;
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (NSString *)description {
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self generateToTransferObject] options:(NSJSONWritingPrettyPrinted) error:NULL];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (instancetype)generateFromObject:(NSDictionary *)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;
    
    ChainAssetAmountObject *obj = [[ChainAssetAmountObject alloc] init];
    
    [obj setValuesForKeysWithDictionary:object];
    
    return obj;
}

- (id)generateToTransferObject {
    return @{@"asset_id":[_assetId generateToTransferObject],@"amount":@(_amount)};
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:20];
    
    [data appendData:[CocosPackData packLongValue:_amount]];
    
    [data appendData:[_assetId transformToData]];
    
    return [data copy];
}
@end
