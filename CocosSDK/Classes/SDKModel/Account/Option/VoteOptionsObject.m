//
//  VoteOptionsObject.m
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/10/15.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "VoteOptionsObject.h"
#import "CocosPublicKey.h"
#import "NSObject+DataToObject.h"
#import "CocosPackData.h"

@implementation VoteOptionsObject

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

+ (instancetype)generateFromObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;
    
    return [[self alloc] initWithDic:object];
}

- (id)generateToTransferObject {
    return [self defaultGetDictionary];
}

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
