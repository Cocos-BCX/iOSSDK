//
//  CocosBase58Object.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>

@interface CocosBase58Object : NSObject
/**
 Convert the specified byte string to base58
 
 @param byteData Byte string
 @return base58Sting
 */
+ (NSString *)encode:(NSData *)byteData;
/**
 Decrypt from base58 string
 
 @param base58String base58String
 @return Decrypted binary data
 */
+ (NSData *)decodeWithBase58String:(NSString *)base58String;

/**
 Base58 transcoding contains transcoding check bits (sha256 check bits)
 
 @param checkSumData Transcoding binary data
 @return Base58 string containing the last 4-bit checkpoint (Sha256)
 */
+ (NSString *)encodeWithSha256CheckSum:(NSData *)checkSumData;

/**
 Base58 string containing the last 4-bit checkpoint (Sha256)

 @param base58StringCheckSum base58String
 @return Original binary data (after sha256 removal)
 */
+ (NSData *)decodeWithSha256Base58StringCheckSum:(NSString *)base58StringCheckSum;

/**
 Base58 transcoding contains transcoding check bits (RIPEMD160 check bits)
 
 @param checkSumData Transcoding binary data
 @return Base58 string containing the last 4-bit test bit (RIPEMD160)
 */
+ (NSString *)encodeWithRIPEMD160CheckSum:(NSData *)checkSumData;

+ (NSData *)decodeWithRIPEMD160Base58StringCheckSum:(NSString *)base58StringCheckSum;

@end
