//
//  Cocos_Key_Account.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/4.
//

#import <Foundation/Foundation.h>

@interface Cocos_Key_Account : NSObject

/**
 getRandomSeed
 */
+ (NSString *)getRandomSeed;

/**
 validate wif format
 */
+ (BOOL)validateWif:(NSString *)wif;

/**
 getRandomBytesDataWithWif
 */
+ (NSData*)getRandomBytesDataWithWif:(NSString *)wif;

/**
 wif_with_random_bytes_data
 @param random_bytesData random_bytesData
 @return wif
 */
+ (NSString *)wif_with_random_bytes_data:(NSData *)random_bytesData;
/**
 private_with_seed
 @param seed seed
 @return private
 */
+ (NSString *)private_with_seed:(NSString *)seed;

/**
 publicKey_with_seed
 @param seed seed
 @return publicKey
 */
+ (NSString *)publicKey_with_seed:(NSString *)seed;

/**
 cocos_publicKey_with_wif
 
 @param wif wif
 @return cocos_publicKey
 */
+ (NSString *)cocos_publicKey_with_wif:(NSString *)wif;

/**
 encode uecc_publicKey --> cocos_PublicKey
 @param uecc_publicKey_bytes_data uecc_publicKey_bytes_data
 @return cocos_PublicKey
 */
+ (NSString *)encode_cocos_PublicKey_with_uecc_publicKey_bytes_data:(NSData *)uecc_publicKey_bytes_data;

/**
 decode cocos_PublicKey --> uecc_publicKey_bytes_data
 @param cocos_publicKey uecc_publicKey_bytes_data
 @return uecc_publicKey_bytes_data
 */
+ (NSData *)decode_cocos_publicKey:(NSString *)cocos_publicKey;

@end

