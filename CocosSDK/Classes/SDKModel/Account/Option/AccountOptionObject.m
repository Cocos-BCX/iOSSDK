//
//  AccountOptionObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "AccountOptionObject.h"
#import "NSObject+DataToObject.h"
#import "VoteIdObject.h"
@implementation AccountOptionObject
- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    if ([key isEqualToString:@"votes"]) {
        self.votes = [VoteIdObject generateFromDataArray:value];
        return;
    }

    value = [self defaultGetValue:value forKey:key];
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

+ (instancetype)generateFromObject:(NSDictionary *)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;
    
    return [[self alloc] initWithDic:object];
}

- (id)generateToTransferObject {
    return [self defaultGetDictionary];
}

@end
