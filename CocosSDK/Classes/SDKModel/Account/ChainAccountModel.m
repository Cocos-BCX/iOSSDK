//
//  ChainAccountModel.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainAccountModel.h"
#import "AccountOptionObject.h"
#import "ChainObjectId.h"
#import "NSObject+DataToObject.h"
#import "AuthorityObject.h"
#import "CocosPublicKey.h"
@implementation ChainAccountModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"identifier"];
        return;
    }
    
    NSArray *array = @[@"whitelisting_accounts",@"blacklisting_accounts",@"whitelisted_accounts",@"blacklisted_accounts"];
    if ([array containsObject:key]) {
        [super setValue:[ChainObjectId generateFromDataArray:value] forKey:key];
        return;
    }
    
    id obj = [self defaultGetValue:value forKey:key];
    
    if (!obj) obj = value;
    
    [super setValue:obj forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

+ (instancetype)generateFromObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;
    
    return [[self alloc] initWithDic:object];
}
//
- (id)generateToTransferObject {
    NSMutableDictionary *dic = [[self defaultGetDictionary] mutableCopy];
    
    dic[@"id"] = dic[@"identifier"];
    
    dic[@"identifier"] = nil;
    
    return [dic copy];
}

- (BOOL)containPublicKey:(CocosPublicKey *)publicKey {
    return [self.owner containPublicKey:publicKey] || [self.active containPublicKey:publicKey] || [self.options.memo_key isEqual:publicKey];
}

- (NSUInteger)hash {
    return [self.name hash];
}

- (BOOL)isEqual:(ChainAccountModel *)object {
    if (![object isKindOfClass:[self class]]) return NO;
    
    return [object.name isEqualToString:self.name] && [object.identifier.generateToTransferObject isEqual:self.identifier.generateToTransferObject];
}

@end
