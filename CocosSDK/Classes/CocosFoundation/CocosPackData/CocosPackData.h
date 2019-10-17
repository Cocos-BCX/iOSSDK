//
//  CocosPackData.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//
//  Converting to NSData Tools

#import <Foundation/Foundation.h>

@interface CocosPackData : NSObject

+ (NSData *)packShort:(short)value;

+ (NSData *)packInt:(int)value;

+ (NSData *)packUnsigedInteger:(NSInteger)value;

+ (NSInteger)unpackUnsignedIntegerWithData:(NSData *)data byteLength:(int *)byteLength;

+ (NSData *)packLongValue:(long)value;

+ (NSData *)packUInt64_T:(uint64_t)value;

+ (NSData *)packUInt32_T:(uint32_t)value;

+ (NSData *)packBool:(BOOL)boolValue;

+ (NSData *)packDate:(NSDate *)date;

+ (NSData *)packString:(NSString *)string;

@end
