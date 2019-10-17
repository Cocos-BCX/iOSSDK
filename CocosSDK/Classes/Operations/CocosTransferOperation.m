//
//  CocosTransferOperation.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosTransferOperation.h"
#import "ChainAssetAmountObject.h"
#import "ChainObjectId.h"
#import "ChainMemo.h"
#import "CocosPackData.h"
#import "NSData+HashData.h"
#import "ChainAssetObject.h"

@implementation CocosTransferOperation

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
    if ([key isEqualToString:@"from"]) {
        self.from = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"to"]) {
        self.to = [ChainObjectId generateFromObject:value];
        return;
    }
    
    if ([key isEqualToString:@"memo"]) {
        self.memo = [ChainMemo generateFromObject:value];
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:6];
    
//    dic[@"fee"] = [self.fee generateToTransferObject];
    
    dic[@"from"] = [self.from generateToTransferObject];
    
    dic[@"to"] = [self.to generateToTransferObject];
    
    dic[@"amount"] = [self.amount generateToTransferObject];
    
    dic[@"memo"] = [self.memo generateToTransferObject];
    
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
    
    [mutableData appendData:[self.from transformToData]];
    
    [mutableData appendData:[self.to transformToData]];
    
    [mutableData appendData:[self.amount transformToData]];
    
    BOOL memoExist = self.memo != nil;
    
    [mutableData appendData:[CocosPackData packBool:memoExist]];
    
    if (memoExist) {
        NSData *memoData =[self.memo transformToData];
        
        [mutableData appendData:memoData];
    }
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}

@end
