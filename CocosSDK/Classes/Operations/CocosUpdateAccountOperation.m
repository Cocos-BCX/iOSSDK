//
//  CocosUpdateAccountOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/10/15.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosUpdateAccountOperation.h"
#import "NSObject+DataToObject.h"
#import "CocosPackData.h"
#import "ChainAssetAmountObject.h"
#import "ChainObjectId.h"
#import "AuthorityObject.h"

@implementation CocosUpdateAccountOperation

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
    
    if ([key isEqualToString:@"new_options"]) {
        [self setValue:value forKey:@"options"];
        return;
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
    
    dic[@"new_options"] = dic[@"options"];
    
    dic[@"options"] = nil;
    
    return [dic copy];

}


- (NSData *)transformToData {
    
    NSMutableData *mutableData = [NSMutableData dataWithCapacity:300];
  
    if (self.lock_with_vote) {
        [mutableData appendData:[CocosPackData packBool:YES]];
        [mutableData appendData:[CocosPackData packUInt32_T:[self.lock_with_vote.firstObject integerValue]]];
        [mutableData appendData:[self.lock_with_vote.lastObject transformToData]];
    }else{
        [mutableData appendData:[CocosPackData packBool:NO]];
    }
    
    [mutableData appendData:[self.account transformToData]];
    
    // 先判断owner 是否有值，有值为1 ，无值为0
    if (self.owner) {
        [mutableData appendData:[CocosPackData packBool:YES]];
        [mutableData appendData:[self.owner transformToData]];
    }else{
        [mutableData appendData:[CocosPackData packBool:NO]];
    }
    
    if (self.active) {
        [mutableData appendData:[CocosPackData packBool:YES]];
        [mutableData appendData:[self.active transformToData]];
    }else{
        [mutableData appendData:[CocosPackData packBool:NO]];
    }
    // 再判断owner 是否有值，有值为1 ，无值为0
    // 两个都没值
    
    [mutableData appendData:[self.options transformToData]];
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}

@end
