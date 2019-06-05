//
//  ChainAssetObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainAssetObject.h"
#import "NSObject+DataToObject.h"
#import "ChainAssetAmountObject.h"
#import "ChainObjectId.h"

@implementation ChainAssetObject

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
    NSMutableDictionary *dic = [[self defaultGetDictionary] mutableCopy];
    
    dic[@"id"] = dic[@"identifier"];
    
    dic[@"identifier"] = nil;
    
    return dic;
}

- (BOOL)isBitAsset {
    return _bitasset_data_id != nil;
}

- (ChainAssetAmountObject *)getAmountFromNormalFloatString:(NSString *)string {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:string];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundUp
                                       scale:0
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:YES];

    
    
    number = [number decimalNumberByMultiplyingByPowerOf10:self.precision withBehavior:roundUp];
    
    ChainAssetAmountObject *asset = [[ChainAssetAmountObject alloc] initFromAssetId:self.identifier amount:number.longValue];
    
    return asset;
}

- (NSString *)getRealAmountFromAssetAmount:(ChainAssetAmountObject *)assetAmount {
    if (assetAmount.assetId.instance != self.identifier.instance) return nil;
    
    
    NSDecimalNumber *demicimal = [NSDecimalNumber decimalNumberWithMantissa:assetAmount.amount exponent:-self.precision isNegative:NO];
    
    return demicimal.stringValue;
}

@end
