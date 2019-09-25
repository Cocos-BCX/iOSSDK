//
//  CocosUpgradeMemberOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/7/8.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosUpgradeMemberOperation.h"
#import "ChainObjectId.h"
#import "ChainAssetAmountObject.h"
#import "CocosPackData.h"

@implementation CocosUpgradeMemberOperation
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:8];
    
//    dic[@"fee"] = [self.fee generateToTransferObject];
    dic[@"account_to_upgrade"] = [self.account_to_upgrade generateToTransferObject];
    dic[@"upgrade_to_lifetime_member"] = @(self.upgrade_to_lifetime_member);
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
    [mutableData appendData:[self.account_to_upgrade transformToData]];
    
    NSData *upgrade_to_lifetimeData = [CocosPackData packBool:self.upgrade_to_lifetime_member];
    [mutableData appendData:upgrade_to_lifetimeData];
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}

@end
