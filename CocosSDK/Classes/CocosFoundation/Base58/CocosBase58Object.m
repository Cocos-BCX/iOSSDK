//
//  CocosBase58Object.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosBase58Object.h"
#import "NSData+HashData.h"
#import "NSData+CopyWithRange.h"

@implementation CocosBase58Object

+ (NSString *)charSetString {
    return @"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
}

+ (NSArray <NSNumber *>*)indexes {
    static NSArray *indexes = nil;
    
    if (!indexes) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:128];
        
        for (int i = 0; i < 128; i ++) {
            [array addObject:@-1];
        }
        
        NSString *string = [self charSetString];
        
        for (int i = 0; i < string.length; i ++) {
            array[[string characterAtIndex:i]] = @(i);
        }
        
        indexes = array;
    }
    return indexes;
}

/**
 Convert the specified byte string to base58
 
 @param byteData Byte string
 @return base58Sting
 */
+ (NSString *)encode:(NSData *)byteData {
    if (!byteData.length) return @"";
    NSUInteger length = byteData.length;
    
    Byte *totalBytes = (Byte*)malloc(length);
    
    memcpy(totalBytes, [byteData bytes], length);
    // 计算字节中为0的个数
    int zeroCount = 0;
    
    while (zeroCount < length && totalBytes[zeroCount] == 0) {
        ++zeroCount;
    }
    
    NSInteger tempLength = length * 2;
    NSInteger j = tempLength;
    
    Byte *tempByte = (Byte*)malloc(tempLength);
    
    int startAt = zeroCount;
    
    while (startAt < length) {
        int mod = [self divMod58ByBytes:totalBytes length:length startAt:startAt];
        
        if (totalBytes[startAt] == 0) {
            ++startAt;
        }
        
        tempByte[--j] = [[self charSetString] characterAtIndex:mod];
    }
    
    while (j < tempLength && tempByte[j] == [[self charSetString] characterAtIndex:0]) {
        ++j;
    }
    
    while (--zeroCount >= 0) {
        tempByte[--j] = [[self charSetString] characterAtIndex:0];
    }
    
    NSData *finalData = [self copyData:tempByte range:NSMakeRange(j, tempLength - j)];
    
    free(tempByte);
    
    free(totalBytes);
    
    return [[NSString alloc] initWithData:finalData encoding:NSASCIIStringEncoding];
}
/**
 从base58字符串中解密

 @param base58String base58字符串
 @return 解密后二进制数据
 */
+ (NSData *)decodeWithBase58String:(NSString *)base58String {
    if (base58String.length == 0) return nil;
    
    NSData *data = [base58String dataUsingEncoding:NSASCIIStringEncoding];
    
    Byte *baseByte = (Byte *)data.bytes;
    
    Byte *input58 = (Byte *)malloc(data.length);
    
    for (int i = 0; i < data.length; i ++) {
        char c = baseByte[i];
        
        int digit58 = -1;
        
        if (c >= 0) {
            digit58 = [[self indexes][c] intValue];
        }
        
        if (digit58 < 0) return nil;
        
        input58[i] = digit58;
    }
    
    int zeroCount = 0;
    while (zeroCount < data.length && input58[zeroCount] == 0) {
        ++zeroCount;
    }
    
    Byte *temp = (Byte *)malloc(data.length);
    
    NSUInteger j = data.length;
    
    int startAt = zeroCount;
    while (startAt < data.length) {
        int mod = [self divMod256ByBytes:input58 length:data.length startAt:startAt];
        if (input58[startAt] == 0) {
            ++startAt;
        }
        temp[--j] = mod;
    }
    
    while (j < data.length && temp[j] == 0) {
        ++j;
    }
    
    NSData *finalData = [self copyData:temp range:NSMakeRange(j - zeroCount, data.length - (j - zeroCount))];
    
    free(temp);
    return finalData;
}

+ (NSString *)encodeWithSha256CheckSum:(NSData *)checkSumData {
    Byte *copyData = (Byte *)malloc(checkSumData.length + 4);
    
    for (int i = 0; i < checkSumData.length; i ++ ) {
        copyData[i] = ((Byte *)checkSumData.bytes)[i];
    }
    
    NSData *doubleSha256Data = [checkSumData doubleSha256Data];
    
    for (int i = 0; i < 4; i ++) {
        copyData[checkSumData.length + i] = ((Byte *)doubleSha256Data.bytes)[i];
    }
    
    NSData *tempData = [NSData dataWithBytes:copyData length:checkSumData.length + 4];
    
    free(copyData);
    
    return [self encode:tempData];
}


+ (NSData *)decodeWithSha256Base58StringCheckSum:(NSString *)base58StringCheckSum {
    NSData *data = [self decodeWithBase58String:base58StringCheckSum];
    
    if (data.length < 4) return nil;

    NSData *finalBytes = [data copyWithRange:NSMakeRange(0, data.length - 4)];
    
    NSData *checkSum = [data copyWithRange:NSMakeRange(data.length-4, 4)];
    
    NSData *doubleSha256Data = [finalBytes doubleSha256Data];
    
    for (int i = 0; i < 4; i ++) {
        Byte a = ((Byte *)checkSum.bytes)[i];
        
        Byte b = ((Byte *)doubleSha256Data.bytes)[i];
        
        if (a != b) return nil;
    }
    
    return finalBytes;
}

+ (NSString *)encodeWithRIPEMD160CheckSum:(NSData *)checkSumData{
    NSData *ripemd160Data = [checkSumData RIPEMD160Data];
    
    NSMutableData *data = [NSMutableData dataWithData:checkSumData];
    
    [data appendBytes:ripemd160Data.bytes length:4];
    
    return [self encode:data];
}

+ (NSData *)decodeWithRIPEMD160Base58StringCheckSum:(NSString *)base58StringCheckSum {
    NSData *data = [self decodeWithBase58String:base58StringCheckSum];
    
    NSData *checkSumData = [data copyWithRange:NSMakeRange(data.length - 4, 4)];
    
    NSData *keyData = [data copyWithRange:NSMakeRange(0, data.length - 4)];
    
    NSData *ripemd160Data = [keyData RIPEMD160Data];
    
    if (![[ripemd160Data copyWithRange:NSMakeRange(0, 4)] isEqualToData:checkSumData]) return nil;
    
    return keyData;
}

/**
Gets the specified base58 string and returns the specified position

 @param bytes 指定base58 byte
 @param byteLength Byte array length
 @param startAt startAt
 @return A figure less than 58
 */
+ (Byte)divMod58ByBytes:(Byte *)bytes length:(NSUInteger)byteLength startAt:(NSUInteger)startAt {
    int remainder = 0;
    for (NSUInteger i = startAt; i < byteLength; i ++) {
        int digit256 = bytes[i] & 0xFF;
        
        int temp = remainder * 256 + digit256;
        
        bytes[i] = temp / 58;
        
        remainder = temp % 58;
    }
    return (Byte)remainder;
}

/**
 Mutually reversible with the above

 @param bytes 指定base58 byte
 @param byteLength Byte array length
 @param startAt startAt
 @return A number less than 256
 */
+ (Byte)divMod256ByBytes:(Byte *)bytes length:(NSUInteger)byteLength startAt:(NSUInteger)startAt {
    int remainder = 0;
    for (NSUInteger i = startAt; i < byteLength; i ++) {
        int digit256 = bytes[i] & 0xFF;
        
        int temp = remainder * 58 + digit256;
        
        bytes[i] = temp / 256;
        
        remainder = temp % 256;
    }
    return (Byte)remainder;
}


/**
 Copy the specified byte array

 @param data data array
 @param range Replication scope
 @return A new byte
 */
+ (NSData *)copyData:(Byte[])data range:(NSRange)range {
    Byte *tempByte = (Byte *)malloc(range.length);
    
    for (int i = 0; i < range.length; i ++) {
        tempByte[i] = data[i + range.location];
    }
    
    NSData *copyData = [NSData dataWithBytes:tempByte length:range.length];
    
    free(tempByte);
    
    return copyData;
}

@end
