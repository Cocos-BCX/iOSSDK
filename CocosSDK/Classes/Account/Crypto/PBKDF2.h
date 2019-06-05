//
//  PBKDF2.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonKeyDerivation.h>

extern NSString* const kSHA1;
//extern NSString* const kSHA256;
//extern NSString* const kSHA512;

@interface PBKDF2 : NSObject

+ (NSData *)pbkdf2:(NSString *)password salt:(NSString *) s count:(int) c kLen:(int) l withAlgo:(NSString *) algo;
+ (NSData *)pbkdf2:(NSString *)password salt:(NSString *) s count:(int) c kLen:(int) l;

+ (NSString *)pass_hash:(NSString *) password length:(int) l count:(int) c saltLength:(int)sl withAlgo:(NSString *)algo;
+ (NSString *)pass_hash:(NSString *) password length:(int) l count:(int) c saltLength:(int)sl;
+ (NSString *)pass_hash:(NSString *) password length:(int) l count:(int) c withAlgo:(NSString *)algo;
+ (NSString *)pass_hash:(NSString *) password length:(int) l count:(int) c;
+ (NSString *)pass_hash:(NSString *) password length:(int) l;
+ (NSString *)pass_hash:(NSString *) password;

+ (BOOL)pass_verify:(NSString *) password hash:(NSString *) h;

+ (NSString *) rand_str:(int) l;
+ (CCPBKDFAlgorithm) getAlgoType:(NSString *) algo;

@end
