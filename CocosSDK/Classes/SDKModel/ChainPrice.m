//
//  ChainPrice.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainPrice.h"
#import "NSObject+DataToObject.h"
#import "ChainAssetAmountObject.h"
@implementation ChainPrice

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
    return [self defaultGetDictionary];
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData data];
    
    [data appendData:_base.transformToData];
    [data appendData:_quote.transformToData];
    
    return data.copy;
}

@end
