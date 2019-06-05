//
//  CocosPublicKey.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@interface CocosPublicKey : NSObject<ObjectToDataProtocol,NSCopying>

@property (nonatomic, copy, readonly) NSData *keyData;

/**
 根据公钥二进制得到公钥

 @param keyData 公钥二进制数据
 @return 公钥
 */
- (instancetype)initWithKeyData:(NSData *)keyData;
/**
 根据公钥的base58字符串得到公钥

 @param pubKeyString 公钥字符串(不包含前缀)
 @return 公钥
 */
- (instancetype)initWithPubkeyString:(NSString *)pubKeyString;
/**
 根据公钥的base58字符串得到公钥
 
 @param pubKeyString 公钥字符串(包含前缀)
 @return 公钥
 */
- (instancetype)initWithAllPubkeyString:(NSString *)pubKeyString;
/**
 根据签名数据和原数据恢复公钥

 @param signCompactSigntures 签名数据
 @param sha256Data 原数据
 @param checkCanonical 是否权威检测
 @return 公钥
 */
- (instancetype)initWithSignCompactSigntures:(NSString *)signCompactSigntures sha256Data:(NSData *)sha256Data checkCanonical:(BOOL)checkCanonical;

- (instancetype)initWithSignCompactData:(NSData *)signCompactData sha256Data:(NSData *)sha256Data checkCanonical:(BOOL)checkCanonical;

+ (BOOL)isCanonical:(Byte *)datas;

@end
