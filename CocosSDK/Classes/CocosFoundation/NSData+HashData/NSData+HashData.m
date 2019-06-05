//
//  NSData+HashData.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "NSData+HashData.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "RIPEMD160Diggest.h"

@implementation NSData (HashData)

- (NSData *)sha256Data {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(self.bytes, (CC_LONG)self.length, digest);
    NSData *outs = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    return outs;
}

- (NSData *)doubleSha256Data {
    return [[self sha256Data] sha256Data];
}

- (NSData *)sha224Data {
    uint8_t digest[CC_SHA224_DIGEST_LENGTH] = {0};
    CC_SHA224(self.bytes, (CC_LONG)self.length, digest);
    NSData *outs = [NSData dataWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
    return outs;
}

- (NSData *)sha512Data {
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
    CC_SHA512(self.bytes, (CC_LONG)self.length, digest);
    NSData *outs = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    return outs;
}

- (NSData *)RIPEMD160Data {
    Byte *outBytes = (Byte *)malloc(20);
    
    Diggest *diggest = [[RIPEMD160Diggest alloc] init];
    
    [diggest updateWithInData:self range:NSMakeRange(0, self.length)];
    
    [diggest doFinalWithByteData:outBytes outOffSet:0];
    
    NSData *data = [NSData dataWithBytes:outBytes length:20];
    
    free(outBytes);
    
    return data;
}

- (void)logDataDetail:(NSString *)test {
    Byte *outBytes = (Byte *)self.bytes;
    
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@ Data:",test];
    
    for (int i = 0; i < self.length; i ++) {
        [string appendFormat:@"%d ",(char)outBytes[i]];
    }
    
    NSLog(@"%@",string);
}

- (NSData *)aes256CBCWithLock:(BOOL)lock keyData:(NSData *)keyData ivData:(NSData *)ivData {
    NSData *retData = nil;
    if (!keyData || !ivData) {
        return nil;
    }
    
    if (keyData.length!=32) {
        return nil;
    }
    
    if (ivData.length != 16) {
        return nil;
    }
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus;
    
    Byte *iv = (Byte *)ivData.bytes;
    
    if (lock) {
        cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,//使用AES算法
                              kCCOptionPKCS7Padding,
                              keyData.bytes, kCCKeySizeAES256,
                              iv,
                              [self bytes], dataLength,
                              buffer, bufferSize,
                              &numBytesEncrypted);
    }else {
        cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                              kCCOptionPKCS7Padding,
                              keyData.bytes, kCCKeySizeAES256,
                              iv,
                              [self bytes], dataLength,
                              buffer, bufferSize,
                              &numBytesEncrypted);
    }
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    
    return retData;
}

- (NSData *)aes256Decrypt:(NSData *)keyData ivData:(NSData *)ivData {
    return [self aes256CBCWithLock:NO keyData:keyData ivData:ivData];
}

- (NSData *)aes256Encrypt:(NSData *)keyData ivData:(NSData *)ivData {
    return [self aes256CBCWithLock:YES keyData:keyData ivData:ivData];
}

@end
