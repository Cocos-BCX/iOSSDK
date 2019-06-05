//
//  Cocos_Key_Account.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/4.
//

#import "Cocos_Key_Account.h"
#include "sha2.h"
#import "Sha256.h"
#include "uECC.h"
#include "libbase58.h"
#include "rmd160.h"
#include <errno.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#import "CocosSetting.h"
#import "CocosConfig.h"
#import "WordList.h"

#define Mnemonic_KEY_WORD_COUNT 16

@implementation Cocos_Key_Account

/**
 getRandomSeed
 */
+ (NSString *)getRandomSeed
{
    NSMutableString *string = [NSMutableString stringWithCapacity:Mnemonic_KEY_WORD_COUNT * 8];
    for (int i = 0; i < Mnemonic_KEY_WORD_COUNT; i ++) {
        if (i > 0) {
            [string appendString:@" "];
        }
        [string appendString:[NSString stringWithUTF8String:word_list[arc4random()%word_list_size]]];
    }
    return [string uppercaseString];
}
/**
 validate wif format
 */
+ (BOOL)validateWif:(NSString *)wif{
    if (!(wif.length > 0)) {
        SDKLog(@"parameter wif can't be nil!");
        return NO;
    }
    const char *b58 = [wif UTF8String];
    unsigned char bin[100];
    size_t binlen=37;
    b58tobin(bin, &binlen, b58, strlen(b58));
    if (bin[0] != 0x80) {
        SDKLog(@"parameter wif header bytes validate failed!");
        return NO;
    }
    unsigned char hexChar[32]; // getRandomHexBytes[32]
    unsigned char digest[32];
    unsigned char result[32]; // Recieve randomHexByes hash result
    unsigned char last4Bytes[4];
    memcpy(hexChar, bin+1, 32);
    memcpy(last4Bytes, bin+33, 4);
    sha256_Raw(hexChar, 33, digest);
    sha256_Raw(digest, 32, digest);
    memcpy(result, digest, 4);
    if (!strcmp(result, last4Bytes) ) {
        SDKLog(@"parameter wif hash validate failed!");
        return NO;
    }
    return YES;
}

/**
 getRandomBytesDataWithWif
 */
+ (NSData*)getRandomBytesDataWithWif:(NSString *)wif{
    if (!(wif.length > 0)) {
        SDKLog(@"parameter wif can't be nil!");
        return nil;
    }
    const char *b58 = [wif UTF8String];
    unsigned char bin[100];
    size_t binlen=37;
    b58tobin(bin, &binlen, b58, strlen(b58));
    if (bin[0] != 0x80) {
        SDKLog(@"parameter wif header bytes validate failed!");
        return nil;
    }
    unsigned char hexChar[33]; // getRandomHexBytes[33]
    unsigned char digest[32];
    unsigned char result[32]; // Recieve randomHexByes hash result
    unsigned char last4Bytes[4];
    memcpy(hexChar, bin+1, 32);
    memcpy(last4Bytes, bin+33, 4);
    sha256_Raw(hexChar, 33, digest);
    sha256_Raw(digest, 32, digest);
    memcpy(result, digest, 4);
    if (!strcmp(result, last4Bytes) ) {
        SDKLog(@"parameter wif hash validate failed!");
        return nil;
    }
    NSData *data = [NSData dataWithBytes:hexChar length:32];
    return data;
}

/**
 wif_with_random_bytes_data
 @param random_bytesData random_bytesData
 @return wif
 */
+ (NSString *)wif_with_random_bytes_data:(NSData *)random_bytesData{
    const char *privateKey = [random_bytesData bytes];
    //    memcpy(str, privateKey, 32);
    unsigned char result[37];
    result[0] = 0x80;
    unsigned char digest[32];
#ifdef DEBUG
    int len;
#else
    unsigned long len;
#endif
    char wif[100];
    memcpy(result + 1 , privateKey, 32);
    sha256_Raw(result, 33, digest);
    sha256_Raw(digest, 32, digest);
    memcpy(result+33, digest, 4);
    b58enc(wif, &len, result,37);
    return [NSString stringWithUTF8String:wif];
}

/**
 private_with_seed
 @param seed seed
 @return private
 */
+ (NSString *)private_with_seed:(NSString *)seed
{
    NSData *seedData = [seed dataUsingEncoding:NSUTF8StringEncoding];
    Sha256 *sha256 = [[Sha256 alloc] initWithData:seedData];
    NSData *sha256HashData = sha256.mHashBytesData;
    
    NSString *private = [Cocos_Key_Account wif_with_random_bytes_data:sha256HashData];
    return private;
}
/**
 publicKey_with_seed
 @param seed seed
 @return publicKey
 */
+ (NSString *)publicKey_with_seed:(NSString *)seed
{
    NSData *seedData = [seed dataUsingEncoding:NSUTF8StringEncoding];
    Sha256 *sha256 = [[Sha256 alloc] initWithData:seedData];
    NSData *sha256HashData = sha256.mHashBytesData;
    
    NSString *private = [Cocos_Key_Account wif_with_random_bytes_data:sha256HashData];
    return [Cocos_Key_Account cocos_publicKey_with_wif:private];
}

/**
 cocos_publicKey_with_wif
 
 @param wif wif
 @return cocos_publicKey
 */
+ (NSString *)cocos_publicKey_with_wif:(NSString *)wif{
    unsigned char pri[32];
    const char *baprik = [wif UTF8String];
    unsigned char result[37];
    unsigned char digest[32];
    char base[100];
    unsigned char *hash;
    size_t len = 100;
    size_t klen = 37;
    
    uint8_t pub[64];
    uint8_t cpub[33];
    
    if (b58tobin(result, &klen, baprik, wif.length)) {
//        printf("success\n");
    }
    
    memcpy(pri, result+1, 32);

    uECC_compute_public_key(pri, pub);
    
    result[0] = 0x80;
    memcpy(result+1, pri, 32);
    sha256_Raw(result, 33, digest);
    sha256_Raw(digest, 32, digest);
    memcpy(result+33, digest, 4);
    b58enc(base, &len, result, 37);
    
    uECC_compress(pub, cpub);
    hash = RMD(cpub, 33);
    memcpy(result, cpub, 33);
    memcpy(result+33, hash, 4);
    b58enc(base, &len, result, 37);

    NSString *cocosPubKey = [NSString stringWithFormat:@"%@%@", [CocosConfig prefix],[NSString stringWithUTF8String:base]];
    return cocosPubKey;
}

/**
 encode uecc_publicKey --> cocos_PublicKey
 @param uecc_publicKey_bytes_data uecc_publicKey_bytes_data
 @return cocos_PublicKey
 */
+ (NSString *)encode_cocos_PublicKey_with_uecc_publicKey_bytes_data:(NSData *)uecc_publicKey_bytes_data{
    uint8_t pub = [uecc_publicKey_bytes_data bytes];
    uint8_t cpub[33];
    char *hash;
    unsigned char reslt[37];
    char base[100];
#ifdef DEBUG
    int len;
#else
    unsigned long len;
#endif
    uECC_compress(pub,cpub);
    hash = RMD(cpub, 33);
    memcpy(reslt, cpub, 33);
    memcpy(reslt+33, hash, 4);
    b58enc(base, &len, reslt,37);
    return [NSString stringWithFormat:@"%@%@", [CocosConfig prefix] , [NSString stringWithUTF8String:base]];;
}

/**
 decode cocos_PublicKey --> uecc_publicKey_bytes_data
 @param cocos_publicKey uecc_publicKey_bytes_data
 @return uecc_publicKey_bytes_data
 */
+ (NSData *)decode_cocos_publicKey:(NSString *)cocos_publicKey{
    if (!(cocos_publicKey.length > 0)) {
        SDKLog(@"parameter cocos_publicKey can't be nil!");
        return nil;
    }
    if (![cocos_publicKey hasPrefix:[CocosConfig prefix]]) {
        SDKLog(@"parameter cocos_publicKey has not prefix 'COCOS'!");
        return nil;
    }
    const char *b58 = [[cocos_publicKey substringFromIndex:3] UTF8String];
    unsigned char bin[100];
    size_t binlen = 37;
    unsigned char *hash;
    
    unsigned char checkValue[33];
    unsigned char validateHash[4];
    uint8_t pub[64];
    b58tobin(bin, &binlen, b58, strlen(b58));
    
    [self out_Hex:bin andLength:binlen];
    
    memcpy(checkValue, bin, 33 );
    memcpy(validateHash, bin+33, 4);
    
    
    hash = RMD(checkValue, 33);
    
    
    for(int i=0;i<4;i++){
        if(validateHash[i]!=hash[i]){
            SDKLog(@"parameter cocos_publicKey validate failed!");
            return nil;
        }
    }
    
    uECC_decompress(checkValue, pub);
    
    return [NSData dataWithBytes:pub length:sizeof(pub)];
}

#pragma mark - Private
+ (void)out_Hex:(unsigned char * )base andLength:(int)length{
    printf("hex::\n");
    for (int i=0;i<length;i++){
        printf("%02x ",base[i]);
    }
    printf("\n");
}

@end

