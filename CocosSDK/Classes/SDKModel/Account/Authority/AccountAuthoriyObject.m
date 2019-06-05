
//
//  AccountAuthoriyObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "AccountAuthoriyObject.h"
#import "ChainObjectId.h"
#import "CocosPackData.h"
@implementation AccountAuthoriyObject

- (instancetype)initWithAccountId:(ChainObjectId *)accountId weightThreshold:(short)weightThreshold {
    self = [super init];
    if (self) {
        _weight_threshold = weightThreshold;
        _accountId = accountId;
    }
    return self;
}

+ (instancetype)generateFromObject:(NSArray *)object {
    if (![object isKindOfClass:[NSArray class]]) return nil;
    
    ChainObjectId *accountId = [ChainObjectId generateFromObject:object.firstObject];
    
    short weight = [object.lastObject shortValue];
    
    return [[self alloc] initWithAccountId:accountId weightThreshold:weight];
}

- (id)generateToTransferObject {
    return @[_accountId.generateToTransferObject,@(_weight_threshold)];
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:10];
    
    [data appendData:_accountId.transformToData];
    
    [data appendData:[CocosPackData packShort:_weight_threshold]];
    return data;
}

@end
