//
//  KeyAuthorityObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "PublicKeyAuthorityObject.h"
#import "CocosPublicKey.h"
#import "CocosPackData.h"

@implementation PublicKeyAuthorityObject

- (instancetype)initWithPublicKey:(CocosPublicKey *)publicKey weightThreshold:(short)weightThreshold {
    if (self = [super init]) {
        _weight_threshold = weightThreshold;
        _key = publicKey;
    }
    return self;
}

+ (instancetype)generateFromObject:(NSArray *)object {
    if (![object isKindOfClass:[NSArray class]]) return nil;
    
    CocosPublicKey *public = [[CocosPublicKey alloc] initWithAllPubkeyString:object.firstObject];
    
    short weight = [object.lastObject shortValue];
    
    return [[self alloc] initWithPublicKey:public weightThreshold:weight];
}

- (id)generateToTransferObject {
    return @[self.key.description,@(self.weight_threshold)];
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:34];
    
    [data appendData:self.key.keyData];
    
    [data appendData:[CocosPackData packShort:self.weight_threshold]];
    
    return [data copy];
}

@end
