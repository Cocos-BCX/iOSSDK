//
//  CocosBitAddress.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
/**
 Cocos is generate from public key data.
 Address data is public key data do first sha512 then ripemd160
 When conver to string,it append address date's ripemd160 data first 4 byte to checksum like publickey do finaly generate use base58
 
 地址类对象是通过公钥对象生成的
 地址类的二进制数据由公钥二进制数据先进行sha512计算后接下来进行ripemd160计算得到
 地址类转化为字符串算法为ripemd160计算后追加4位字节到地址类的尾部然后将整个24位二进制数据进行base58转换
 */
@interface CocosBitAddress : NSObject

@property (nonatomic, strong, readonly) NSData *keyData;

- (instancetype)initWithKeyData:(NSData *)keyDate;

- (instancetype)initWithBitAddressString:(NSString *)bitAddressString;

//- (instancetype)initWithAllBitAddressString:(NSString *)allBitAddressString;

@end
