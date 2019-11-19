//
//  CocosCreateSonAccountOperation.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/11/19.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosCreateSonAccountOperation.h"
#import "ChainObjectId.h"
#import "AuthorityObject.h"
#import "AccountOptionObject.h"
#import "CocosPackData.h"
#import "NSObject+DataToObject.h"

@implementation CocosCreateSonAccountOperation

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
    
    
    if ([key isEqualToString:@"registrar"]) {
        self.registrar = [ChainObjectId generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"owner"]) {
        self.owner = [AuthorityObject generateFromObject:value];
        return;
    }
    
    if ([key isEqualToString:@"active"]) {
        self.active = [AuthorityObject generateFromObject:value];
        return;
    }
    if ([key isEqualToString:@"options"]) {
        self.options = [AccountOptionObject generateFromObject:value];
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
    
    [mutableData appendData:[self.registrar transformToData]];
    
    [mutableData appendData:[CocosPackData packString:self.name]];
    
    [mutableData appendData:[self.owner transformToData]];
    
    [mutableData appendData:[self.active transformToData]];
    
    [mutableData appendData:[self.options transformToData]];
    
    [mutableData appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [mutableData copy];
}

@end
