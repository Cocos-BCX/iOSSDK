//
//  Diggest.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "Diggest.h"

@implementation Diggest

- (instancetype)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

- (void)reset {
    _byteCount = 0;
    _xBufOff = 0;
    
    for (int i = 0; i < 4; i ++) {
        _xBuf[i] = 0;
    }
}

- (void)updateWithByte:(Byte)byte {
    _xBuf[_xBufOff++] = byte;
    
    if (_xBufOff == 4) {
        [self processWord:[NSData dataWithBytes:_xBuf length:4] location:0];
        _xBufOff = 0;
    }
    
    ++_byteCount;
}

- (void)updateWithInData:(NSData *)inData range:(NSRange)range {
    NSAssert(range.length >= 0 && range.location >= 0, @"Range not valid");
    
    int i = 0;
    
    Byte *bytes = (Byte *)inData.bytes;
    
    if (_xBufOff != 0) {
        while (i < range.length) {
            _xBuf[_xBufOff++] = bytes[range.location + i++];
            if (_xBufOff == 4) {
                [self processWord:[NSData dataWithBytes:_xBuf length:4] location:0];
                _xBufOff = 0;
                break;
            }
        }
    }
    
    for (int limit = (int)(range.length - i & -4) + i; i < limit; i += 4) {
        [self processWord:inData location:(int)range.location + i];
    }
    
    while (i < range.length) {
        _xBuf[_xBufOff++] = bytes[range.location + i++];
    }
    
    _byteCount = (int)range.length;
}

- (void)finish {
    long bitLength = _byteCount << 3;
    [self updateWithByte:(Byte)-128];
    
    while (_xBufOff != 0) {
        [self updateWithByte:(Byte)0];
    }
    
    [self processLength:bitLength];
    [self processBlock];
}

- (int)doFinalWithByteData:(Byte *)byteData outOffSet:(int)outOffSet {
    NSAssert(NO, @"Abstruct class object method doFinalWithByteData:outOffSet: not implement");
    return 0;
}

- (void)processBlock {
    NSAssert(NO, @"Abstruct class object method processBlock not implement");
}

- (void)processLength:(long)bitlength {
    NSAssert(NO, @"Abstruct class object method processLength: not implement");
}

- (void)processWord:(NSData *)wordData location:(int)location {
    NSAssert(NO, @"Abstruct class object method processWord:location: not implement");
}

@end
