//
//  WalletExtraKey.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import "WalletExtraKey.h"
#import "ChainObjectId.h"
#import "CocosPublicKey.h"

#import "NSObject+DataToObject.h"

@implementation WalletExtraKey

+ (instancetype)generateFromObject:(NSArray *)object {
    if (![object isKindOfClass:[NSArray class]]) return nil;
    
    WalletExtraKey *wallet = [[WalletExtraKey alloc] init];
    
    wallet.keyId = [ChainObjectId createFromString:object.firstObject];
    
    NSArray *array = object.lastObject;
    
    NSMutableArray *publicArray = [NSMutableArray arrayWithCapacity:(array.count)];
    
    for (NSString *publicKey in array) {
        [publicArray addObject:[CocosPublicKey generateFromObject:publicKey]];
    }
    
    wallet.keyArray = publicArray;
    
    return wallet;
}

- (id)generateToTransferObject {
    return @[self.keyId.generateToTransferObject,[NSObject generateToTransferArray:self.keyArray]];
}

- (BOOL)containPublicKey:(CocosPublicKey *)publicKey {
    return [self.keyArray containsObject:publicKey];
}

@end
