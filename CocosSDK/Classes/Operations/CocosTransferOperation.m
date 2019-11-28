//
//  CocosTransferOperation.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosTransferOperation.h"
#import "ChainAssetAmountObject.h"
#import "ChainObjectId.h"
#import "ChainEncryptionMemo.h"
#import "CocosPackData.h"
#import "NSData+HashData.h"
#import "ChainAssetObject.h"
#import "NSObject+DataToObject.h"

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
        if ([[(NSArray *)value firstObject] integerValue] == 1) {
            self.memo = @[@(1),[ChainEncryptionMemo generateFromObject:value]];
        }else{
            self.memo = @[@(0),value];
        }
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
        if ([self.memo.firstObject integerValue] == 0) {
            [mutableData appendData:[CocosPackData packBool:NO]];
            [mutableData appendData:[CocosPackData packString:self.memo.lastObject]];
        }else{
            [mutableData appendData:[CocosPackData packBool:YES]];
            NSData *memoData =[self.memo.lastObject transformToData];
            [mutableData appendData:memoData];
        }
    }
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}

@end

