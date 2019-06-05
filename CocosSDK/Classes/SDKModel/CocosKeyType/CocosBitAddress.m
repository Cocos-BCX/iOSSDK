//
//  CocosBitAddress.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosBitAddress.h"
#import "CocosPublicKey.h"
#import "NSData+HashData.h"
#import "CocosConfig.h"
#import "CocosBase58Object.h"

@interface CocosBitAddress ()

@property (nonatomic, strong) NSString *addressString;

@end

@implementation CocosBitAddress

- (instancetype)initWithKeyData:(NSData *)keyData {
    if (self = [super init]) {
        _keyData = [[keyData sha512Data] RIPEMD160Data];
        
        _addressString = [CocosBase58Object encodeWithRIPEMD160CheckSum:_keyData];
    }
    
    return self;
}

- (instancetype)initWithBitAddressString:(NSString *)bitAddressString {
    if (self = [super init]) {
        _addressString = bitAddressString;
        
        _keyData = [CocosBase58Object decodeWithRIPEMD160Base58StringCheckSum:bitAddressString];
    }
    return self;
}

- (instancetype)initWithAllBitAddressString:(NSString *)allBitAddressString {
    allBitAddressString = [allBitAddressString substringFromIndex:[CocosConfig prefix].length];
    
    return [self initWithBitAddressString:allBitAddressString];
}

- (instancetype)initWithPublicKey:(CocosPublicKey *)publicKey {
    if (self = [super init]) {
        _keyData = [[publicKey.keyData sha512Data] RIPEMD160Data];
        
        _addressString = [CocosBase58Object encodeWithRIPEMD160CheckSum:_keyData];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@",[CocosConfig prefix],_addressString];
}

@end
