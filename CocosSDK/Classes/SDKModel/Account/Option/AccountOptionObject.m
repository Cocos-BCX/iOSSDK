//
//  AccountOptionObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "AccountOptionObject.h"
#import "NSObject+DataToObject.h"
#import "VoteIdObject.h"
#import "CocosPackData.h"
#import "CocosPublicKey.h"

@implementation AccountOptionObject



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

//- (NSData *)transformToData {
//    NSMutableData *data = [NSMutableData dataWithCapacity:80];
//
//    [data appendData:[CocosPackData packInt:self.weight_threshold]];
//
//    [data appendData:[CocosPackData packUnsigedInteger:self.account_auths.count]];
//
//    for (id <ObjectToDataProtocol>obj in self.account_auths) {
//        [data appendData:[obj transformToData]];
//    }
//
//    [data appendData:[CocosPackData packUnsigedInteger:self.key_auths.count]];
//
//    for (id <ObjectToDataProtocol>obj in self.key_auths) {
//        [data appendData:[obj transformToData]];
//    }
//
//    [data appendData:[CocosPackData packUnsigedInteger:self.address_auths.count]];
//
//    for (id <ObjectToDataProtocol>obj in self.address_auths) {
//        [data appendData:[obj transformToData]];
//    }
//
//    return [data copy];
//    return nil;
//}


- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData data];
    
    // 判断memo 是否有值，有值为1 ，无值为0
    // 有值
    [data appendData:[CocosPackData packBool:YES]];
    
    [data appendData:self.memo_key.keyData];
    
    [data appendData:[CocosPackData packUnsigedInteger:self.votes.count]];
    for (NSString *voteid  in self.votes) {
        NSArray *array = [voteid componentsSeparatedByString:@":"];
        NSInteger voteType = [[array firstObject] integerValue];
        NSInteger voteId = [[array lastObject] integerValue];
        uint32_t b = voteId << 8 | voteType;
        
        [data appendData:[CocosPackData packInt:b]];
    }
    
    [data appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return data.copy;
}

@end
