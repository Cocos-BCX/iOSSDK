//
//  BitAddressAuthorityObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "BitAddressAuthorityObject.h"
#import "CocosBitAddress.h"
#import "CocosPackData.h"
@implementation BitAddressAuthorityObject

- (instancetype)initWithBitAddress:(CocosBitAddress *)bitAddress weightThreshold:(short)weightThreshold {
    if (self = [super init]) {
        _address = bitAddress;
        _weight_threshold = weightThreshold;
    }
    return self;
}

+ (instancetype)generateFromObject:(NSArray *)object {
    if (![object isKindOfClass:[NSArray class]]) return nil;
    
    CocosBitAddress *address = [[CocosBitAddress alloc] initWithBitAddressString:object.firstObject];
    
    short weight = [object.lastObject shortValue];
    
    return [[self alloc] initWithBitAddress:address weightThreshold:weight];
}

- (id)generateToTransferObject {
    return @[_address.description,@(_weight_threshold)];
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:34];
    
    [data appendData:self.address.keyData];
    
    [data appendData:[CocosPackData packShort:self.weight_threshold]];
    
    return [data copy];
}

@end
