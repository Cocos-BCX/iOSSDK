//
//  AuthorityObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "AuthorityObject.h"
#import "AccountAuthoriyObject.h"
#import "PublicKeyAuthorityObject.h"
#import "BitAddressAuthorityObject.h"
#import "CocosPackData.h"
#import "CocosPublicKey.h"
@implementation AuthorityObject

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(NSArray *)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    NSDictionary *dic = @{@"account_auths":@"AccountAuthoriyObject",@"key_auths":@"PublicKeyAuthorityObject",@"address_auths":@"BitAddressAuthorityObject"};
    
    NSString *cls = dic[key];
    
    if (cls) {
        NSArray *valueArray = [AuthorityObject generateObjectArrayFromTransferArray:value clsName:NSClassFromString(cls)];
        [super setValue:valueArray forKey:key];
        return;
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

+ (instancetype)generateFromObject:(NSDictionary *)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;
    
    return [[self alloc] initWithDic:object];
}

- (id)generateToTransferObject {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    
    dictionary[@"weight_threshold"] = @(self.weight_threshold);
    
    dictionary[@"account_auths"] = [self generateTransferArrayFromBaseArray:self.account_auths];
    
    dictionary[@"key_auths"] = [self generateTransferArrayFromBaseArray:self.key_auths];
    
    dictionary[@"address_auths"] = [self generateTransferArrayFromBaseArray:self.address_auths];
    
    return [dictionary copy];
}

- (NSArray *)generateTransferArrayFromBaseArray:(NSArray <id<ObjectToDataProtocol>>*)baseArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:baseArray.count];
    
    for (id <ObjectToDataProtocol>obj in baseArray) {
        if ([obj respondsToSelector:@selector(generateToTransferObject)]) {
            [array addObject:[obj generateToTransferObject]];
        }
    }
    return [array copy];
}

+ (NSArray *)generateObjectArrayFromTransferArray:(NSArray *)transferArray clsName:(Class <ObjectToDataProtocol>)clsName {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:transferArray.count];
    
    for (id obj in transferArray) {
        [array addObject:[clsName generateFromObject:obj]];
    }
    
    return array;
}

- (BOOL)containPublicKey:(CocosPublicKey *)publicKey {
    __block BOOL result = NO;
    
    [self.key_auths enumerateObjectsUsingBlock:^(PublicKeyAuthorityObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.key isEqual:publicKey]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

- (NSArray<CocosPublicKey *> *)publicKeys {
    NSMutableArray *array = [NSMutableArray array];
    
    [self.key_auths enumerateObjectsUsingBlock:^(PublicKeyAuthorityObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.key];
    }];
    
    return [array copy];
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:80];
    
    [data appendData:[CocosPackData packInt:self.weight_threshold]];
    
    [data appendData:[CocosPackData packUnsigedInteger:self.account_auths.count]];
    
    for (id <ObjectToDataProtocol>obj in self.account_auths) {
        [data appendData:[obj transformToData]];
    }
    
    [data appendData:[CocosPackData packUnsigedInteger:self.key_auths.count]];
    
    for (id <ObjectToDataProtocol>obj in self.key_auths) {
        [data appendData:[obj transformToData]];
    }
    
    [data appendData:[CocosPackData packUnsigedInteger:self.address_auths.count]];
    
    for (id <ObjectToDataProtocol>obj in self.address_auths) {
        [data appendData:[obj transformToData]];
    }
    
    return [data copy];
}

@end
