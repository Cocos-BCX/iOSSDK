//
//  CocosPrivateKey.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#include <assert.h>

#import "CocosPrivateKey.h"
#import "CocosBase58Object.h"
#import "NSData+CopyWithRange.h"
#import "NSData+HashData.h"
#import "NSData+Base16.h"
#import "SHA256Diggest.h"
#import "secp256k1.h"
#import "CocosPublicKey.h"

@interface CocosPrivateKey ()

/**
 32字节长度二进制数据
 */
@property (nonatomic, strong) NSData *keyData;

@end

@implementation CocosPrivateKey

+ (secp256k1_context_t *)getBaseContext {
    static secp256k1_context_t* ctx = NULL;

    if (ctx == NULL) {
        ctx = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY | SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_RANGEPROOF | SECP256K1_CONTEXT_COMMIT);
    }
    return ctx;
}

- (instancetype)initWithKeyData:(NSData *)keyData {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithPrivateKey:(NSString *)privateKey {
    if (self = [super init]) {
        NSData *data = [CocosBase58Object decodeWithSha256Base58StringCheckSum:privateKey];

        if (data.length > 1) {
            _keyData = [data copyWithRange:NSMakeRange(1, data.length - 1)];
        }
    }
    return self;
}

- (CocosPublicKey *)publicKey {

    char *pubkeyData = (char *)malloc(33);
    
    unsigned int pubkeylength;
    
    int result = secp256k1_ec_pubkey_create([CocosPrivateKey getBaseContext], (unsigned char*)pubkeyData, (int *)&pubkeylength, (unsigned char*)self.keyData.bytes, 1);
    
    if (result == 1 && pubkeylength == 33) {
        NSData *data = [NSData dataWithBytes:pubkeyData length:33];
        
        free(pubkeyData);
        
        CocosPublicKey *publicKey = [[CocosPublicKey alloc] initWithKeyData:data];
        
        return publicKey;
    }
    
    free(pubkeyData);
    
    return nil;
}

- (NSString *)description {
    Byte *bytes = (Byte *)malloc(1);

    bytes[0] = 0x80;

    NSMutableData *data = [NSMutableData dataWithBytes:bytes length:1];

    [data appendData:self.keyData];

    return [CocosBase58Object encodeWithSha256CheckSum:data];
}

- (NSData *)getSharedSecret:(CocosPublicKey *)otherPublic {
    Byte *byte = (Byte *)malloc(33);

    for (int i = 0; i < otherPublic.keyData.length; i ++) {
        byte[i] = ((Byte *)otherPublic.keyData.bytes)[i];
    }
    int result = secp256k1_ec_pubkey_tweak_mul( [CocosPrivateKey getBaseContext], (unsigned char*) byte, 33,(unsigned char*)self.keyData.bytes);
    if (result == 1) {
        NSData *totalData = [NSData dataWithBytes:(byte + 1) length:32];

        free(byte);

        return [totalData sha512Data];
    }

    free(byte);

    return nil;
}

static int extended_nonce_function( unsigned char *nonce32, const unsigned char *msg32,
                                   const unsigned char *key32, unsigned int attempt,
                                   const void *data ) {
    unsigned int* extra = (unsigned int*) data;
    (*extra)++;
    return secp256k1_nonce_function_default( nonce32, msg32, key32, *extra, nullptr );
}

- (NSString *)signedCompact:(NSData *)sha256Data requireCanonical:(BOOL)requireCanonical {
    Byte *bytes = (Byte *)malloc(65);

    int recid = -1;

    unsigned int counter = 0;

    do {
        int result = secp256k1_ecdsa_sign_compact([CocosPrivateKey getBaseContext],(unsigned char*) sha256Data.bytes,(unsigned char*)(bytes + 1),(unsigned char*)self.keyData.bytes,extended_nonce_function,&counter,&recid);

        if(result != 1) return nil;
    } while (requireCanonical && ![CocosPublicKey isCanonical:bytes]);

    bytes[0] = 27 + 4 + recid;

    NSData *data = [NSData dataWithBytes:bytes length:65];

    free(bytes);

    return [data base16EncodedStringWithOptions:(NSDataBase16EncodingOptionsLowerCase)];
}

@end
