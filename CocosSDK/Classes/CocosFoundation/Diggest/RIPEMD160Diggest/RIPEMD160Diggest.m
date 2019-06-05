//
//  RIPEMD160Diggest.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "RIPEMD160Diggest.h"

#define DIGEST_LENGTH 20

@interface RIPEMD160Diggest (){
    int _x[16];
}

@property (nonatomic, assign) int H0;
@property (nonatomic, assign) int H1;
@property (nonatomic, assign) int H2;
@property (nonatomic, assign) int H3;
@property (nonatomic, assign) int H4;

@property (nonatomic, assign) int xOff;

@end

@implementation RIPEMD160Diggest

- (void)reset {
    [super reset];
    
    _H0 = 0x67452301;
    _H1 = 0xefcdab89;
    _H2 = 0x98badcfe;
    _H3 = 0x10325476;
    _H4 = 0xc3d2e1f0;
    
    _xOff = 0;
    
    for (int i = 0; i < 16; i++) {
        _x[i] = 0;
    }
}

- (int)doFinalWithByteData:(Byte *)byteData outOffSet:(int)outOffSet {
    void (^intToBigEndian) (int,Byte *,int) = ^(int n,Byte *byteData,int off) {
        
        for (int i = 0; i < 4; i ++) {
            byteData[off + i] = (Byte)((unsigned int)n >> i * 8);
        }
    };
    
    [self finish];
    
    intToBigEndian(_H0,byteData,outOffSet);
    intToBigEndian(_H1,byteData,outOffSet + 4);
    intToBigEndian(_H2,byteData,outOffSet + 8);
    intToBigEndian(_H3,byteData,outOffSet + 12);
    intToBigEndian(_H4,byteData,outOffSet + 16);
    
    [self reset];
    return DIGEST_LENGTH;
}

- (void)processWord:(NSData *)wordData location:(int)location {
    Byte *bytes = (Byte *)wordData.bytes;
    
    _x[_xOff++] = (bytes[location] & 0xff) | ((bytes[location + 1] & 0xff) << 8) | ((bytes[location + 2] & 0xff) << 16)
    | ((bytes[location + 3] & 0xff) << 24);
    
    if (_xOff == 16) {
        [self processBlock];
    }
}

- (void) processLength:(long)bitLength {
    if (_xOff > 14) {
        [self processBlock];
    }
    
    _x[14] = (int) (bitLength & 0xffffffff);
    _x[15] = (int) ((unsigned long)bitLength >> 32);
}

- (void)processBlock {
    int (^RL)(int x, int n) = ^(int x,int n) {
        return (int)((x << n) | ((unsigned int)x >> (32 - n)));
    };
    
    int (^f1)(int x, int y, int z) = ^(int x, int y, int z) {
        return x ^ y ^ z;
    };
    
    int (^f2)(int x, int y, int z) = ^(int x, int y, int z) {
        return (x & y) | (~x & z);
    };
    
    int (^f3)(int x, int y, int z) = ^(int x, int y, int z) {
        return (x | ~y) ^ z;
    };
    
    int (^f4)(int x, int y, int z) = ^(int x, int y, int z) {
        return (x & z) | (y & ~z);
    };
    
    int (^f5)(int x, int y, int z) = ^(int x, int y, int z) {
        return x ^ (y | ~z);
    };
    
    int a, aa;
    int b, bb;
    int c, cc;
    int d, dd;
    int e, ee;
    
    a = aa = _H0;
    b = bb = _H1;
    c = cc = _H2;
    d = dd = _H3;
    e = ee = _H4;

    //
    // Rounds 1 - 16
    //
    // left
  //1
    a = RL(a + f1(b, c, d) + _x[0], 11) + e;
    c = RL(c, 10);
  //5
    e = RL(e + f1(a, b, c) + _x[1], 14) + d;
    b = RL(b, 10);
  //4
    d = RL(d + f1(e, a, b) + _x[2], 15) + c;
    a = RL(a, 10);
    c = RL(c + f1(d, e, a) + _x[3], 12) + b;
    e = RL(e, 10);
    b = RL(b + f1(c, d, e) + _x[4], 5) + a;
    d = RL(d, 10);
    a = RL(a + f1(b, c, d) + _x[5], 8) + e;
    c = RL(c, 10);
    e = RL(e + f1(a, b, c) + _x[6], 7) + d;
    b = RL(b, 10);
    d = RL(d + f1(e, a, b) + _x[7], 9) + c;
    a = RL(a, 10);
    c = RL(c + f1(d, e, a) + _x[8], 11) + b;
    e = RL(e, 10);
    b = RL(b + f1(c, d, e) + _x[9], 13) + a;
    d = RL(d, 10);
    a = RL(a + f1(b, c, d) + _x[10], 14) + e;
    c = RL(c, 10);
    e = RL(e + f1(a, b, c) + _x[11], 15) + d;
    b = RL(b, 10);
    d = RL(d + f1(e, a, b) + _x[12], 6) + c;
    a = RL(a, 10);
    c = RL(c + f1(d, e, a) + _x[13], 7) + b;
    e = RL(e, 10);
    b = RL(b + f1(c, d, e) + _x[14], 9) + a;
    d = RL(d, 10);
    a = RL(a + f1(b, c, d) + _x[15], 8) + e;
    c = RL(c, 10);
    
    // right
    aa = RL(aa + f5(bb, cc, dd) + _x[5] + 0x50a28be6, 8) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f5(aa, bb, cc) + _x[14] + 0x50a28be6, 9) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f5(ee, aa, bb) + _x[7] + 0x50a28be6, 9) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f5(dd, ee, aa) + _x[0] + 0x50a28be6, 11) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f5(cc, dd, ee) + _x[9] + 0x50a28be6, 13) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f5(bb, cc, dd) + _x[2] + 0x50a28be6, 15) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f5(aa, bb, cc) + _x[11] + 0x50a28be6, 15) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f5(ee, aa, bb) + _x[4] + 0x50a28be6, 5) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f5(dd, ee, aa) + _x[13] + 0x50a28be6, 7) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f5(cc, dd, ee) + _x[6] + 0x50a28be6, 7) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f5(bb, cc, dd) + _x[15] + 0x50a28be6, 8) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f5(aa, bb, cc) + _x[8] + 0x50a28be6, 11) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f5(ee, aa, bb) + _x[1] + 0x50a28be6, 14) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f5(dd, ee, aa) + _x[10] + 0x50a28be6, 14) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f5(cc, dd, ee) + _x[3] + 0x50a28be6, 12) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f5(bb, cc, dd) + _x[12] + 0x50a28be6, 6) + ee;
    cc = RL(cc, 10);
    
    //
    // Rounds 16-31
    //
    // left
    e = RL(e + f2(a, b, c) + _x[7] + 0x5a827999, 7) + d;
    b = RL(b, 10);
    d = RL(d + f2(e, a, b) + _x[4] + 0x5a827999, 6) + c;
    a = RL(a, 10);
    c = RL(c + f2(d, e, a) + _x[13] + 0x5a827999, 8) + b;
    e = RL(e, 10);
    b = RL(b + f2(c, d, e) + _x[1] + 0x5a827999, 13) + a;
    d = RL(d, 10);
    a = RL(a + f2(b, c, d) + _x[10] + 0x5a827999, 11) + e;
    c = RL(c, 10);
    e = RL(e + f2(a, b, c) + _x[6] + 0x5a827999, 9) + d;
    b = RL(b, 10);
    d = RL(d + f2(e, a, b) + _x[15] + 0x5a827999, 7) + c;
    a = RL(a, 10);
    c = RL(c + f2(d, e, a) + _x[3] + 0x5a827999, 15) + b;
    e = RL(e, 10);
    b = RL(b + f2(c, d, e) + _x[12] + 0x5a827999, 7) + a;
    d = RL(d, 10);
    a = RL(a + f2(b, c, d) + _x[0] + 0x5a827999, 12) + e;
    c = RL(c, 10);
    e = RL(e + f2(a, b, c) + _x[9] + 0x5a827999, 15) + d;
    b = RL(b, 10);
    d = RL(d + f2(e, a, b) + _x[5] + 0x5a827999, 9) + c;
    a = RL(a, 10);
    c = RL(c + f2(d, e, a) + _x[2] + 0x5a827999, 11) + b;
    e = RL(e, 10);
    b = RL(b + f2(c, d, e) + _x[14] + 0x5a827999, 7) + a;
    d = RL(d, 10);
    a = RL(a + f2(b, c, d) + _x[11] + 0x5a827999, 13) + e;
    c = RL(c, 10);
    e = RL(e + f2(a, b, c) + _x[8] + 0x5a827999, 12) + d;
    b = RL(b, 10);
    
    // right
    ee = RL(ee + f4(aa, bb, cc) + _x[6] + 0x5c4dd124, 9) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f4(ee, aa, bb) + _x[11] + 0x5c4dd124, 13) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f4(dd, ee, aa) + _x[3] + 0x5c4dd124, 15) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f4(cc, dd, ee) + _x[7] + 0x5c4dd124, 7) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f4(bb, cc, dd) + _x[0] + 0x5c4dd124, 12) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f4(aa, bb, cc) + _x[13] + 0x5c4dd124, 8) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f4(ee, aa, bb) + _x[5] + 0x5c4dd124, 9) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f4(dd, ee, aa) + _x[10] + 0x5c4dd124, 11) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f4(cc, dd, ee) + _x[14] + 0x5c4dd124, 7) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f4(bb, cc, dd) + _x[15] + 0x5c4dd124, 7) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f4(aa, bb, cc) + _x[8] + 0x5c4dd124, 12) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f4(ee, aa, bb) + _x[12] + 0x5c4dd124, 7) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f4(dd, ee, aa) + _x[4] + 0x5c4dd124, 6) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f4(cc, dd, ee) + _x[9] + 0x5c4dd124, 15) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f4(bb, cc, dd) + _x[1] + 0x5c4dd124, 13) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f4(aa, bb, cc) + _x[2] + 0x5c4dd124, 11) + dd;
    bb = RL(bb, 10);
    
    //
    // Rounds 32-47
    //
    // left
    d = RL(d + f3(e, a, b) + _x[3] + 0x6ed9eba1, 11) + c;
    a = RL(a, 10);
    c = RL(c + f3(d, e, a) + _x[10] + 0x6ed9eba1, 13) + b;
    e = RL(e, 10);
    b = RL(b + f3(c, d, e) + _x[14] + 0x6ed9eba1, 6) + a;
    d = RL(d, 10);
    a = RL(a + f3(b, c, d) + _x[4] + 0x6ed9eba1, 7) + e;
    c = RL(c, 10);
    e = RL(e + f3(a, b, c) + _x[9] + 0x6ed9eba1, 14) + d;
    b = RL(b, 10);
    d = RL(d + f3(e, a, b) + _x[15] + 0x6ed9eba1, 9) + c;
    a = RL(a, 10);
    c = RL(c + f3(d, e, a) + _x[8] + 0x6ed9eba1, 13) + b;
    e = RL(e, 10);
    b = RL(b + f3(c, d, e) + _x[1] + 0x6ed9eba1, 15) + a;
    d = RL(d, 10);
    a = RL(a + f3(b, c, d) + _x[2] + 0x6ed9eba1, 14) + e;
    c = RL(c, 10);
    e = RL(e + f3(a, b, c) + _x[7] + 0x6ed9eba1, 8) + d;
    b = RL(b, 10);
    d = RL(d + f3(e, a, b) + _x[0] + 0x6ed9eba1, 13) + c;
    a = RL(a, 10);
    c = RL(c + f3(d, e, a) + _x[6] + 0x6ed9eba1, 6) + b;
    e = RL(e, 10);
    b = RL(b + f3(c, d, e) + _x[13] + 0x6ed9eba1, 5) + a;
    d = RL(d, 10);
    a = RL(a + f3(b, c, d) + _x[11] + 0x6ed9eba1, 12) + e;
    c = RL(c, 10);
    e = RL(e + f3(a, b, c) + _x[5] + 0x6ed9eba1, 7) + d;
    b = RL(b, 10);
    d = RL(d + f3(e, a, b) + _x[12] + 0x6ed9eba1, 5) + c;
    a = RL(a, 10);
    
    // right
    dd = RL(dd + f3(ee, aa, bb) + _x[15] + 0x6d703ef3, 9) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f3(dd, ee, aa) + _x[5] + 0x6d703ef3, 7) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f3(cc, dd, ee) + _x[1] + 0x6d703ef3, 15) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f3(bb, cc, dd) + _x[3] + 0x6d703ef3, 11) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f3(aa, bb, cc) + _x[7] + 0x6d703ef3, 8) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f3(ee, aa, bb) + _x[14] + 0x6d703ef3, 6) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f3(dd, ee, aa) + _x[6] + 0x6d703ef3, 6) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f3(cc, dd, ee) + _x[9] + 0x6d703ef3, 14) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f3(bb, cc, dd) + _x[11] + 0x6d703ef3, 12) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f3(aa, bb, cc) + _x[8] + 0x6d703ef3, 13) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f3(ee, aa, bb) + _x[12] + 0x6d703ef3, 5) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f3(dd, ee, aa) + _x[2] + 0x6d703ef3, 14) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f3(cc, dd, ee) + _x[10] + 0x6d703ef3, 13) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f3(bb, cc, dd) + _x[0] + 0x6d703ef3, 13) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f3(aa, bb, cc) + _x[4] + 0x6d703ef3, 7) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f3(ee, aa, bb) + _x[13] + 0x6d703ef3, 5) + cc;
    aa = RL(aa, 10);
    
    //
    // Rounds 48-63
    //
    // left
    c = RL(c + f4(d, e, a) + _x[1] + 0x8f1bbcdc, 11) + b;
    e = RL(e, 10);
    b = RL(b + f4(c, d, e) + _x[9] + 0x8f1bbcdc, 12) + a;
    d = RL(d, 10);
    a = RL(a + f4(b, c, d) + _x[11] + 0x8f1bbcdc, 14) + e;
    c = RL(c, 10);
    e = RL(e + f4(a, b, c) + _x[10] + 0x8f1bbcdc, 15) + d;
    b = RL(b, 10);
    d = RL(d + f4(e, a, b) + _x[0] + 0x8f1bbcdc, 14) + c;
    a = RL(a, 10);
    c = RL(c + f4(d, e, a) + _x[8] + 0x8f1bbcdc, 15) + b;
    e = RL(e, 10);
    b = RL(b + f4(c, d, e) + _x[12] + 0x8f1bbcdc, 9) + a;
    d = RL(d, 10);
    a = RL(a + f4(b, c, d) + _x[4] + 0x8f1bbcdc, 8) + e;
    c = RL(c, 10);
    e = RL(e + f4(a, b, c) + _x[13] + 0x8f1bbcdc, 9) + d;
    b = RL(b, 10);
    d = RL(d + f4(e, a, b) + _x[3] + 0x8f1bbcdc, 14) + c;
    a = RL(a, 10);
    c = RL(c + f4(d, e, a) + _x[7] + 0x8f1bbcdc, 5) + b;
    e = RL(e, 10);
    b = RL(b + f4(c, d, e) + _x[15] + 0x8f1bbcdc, 6) + a;
    d = RL(d, 10);
    a = RL(a + f4(b, c, d) + _x[14] + 0x8f1bbcdc, 8) + e;
    c = RL(c, 10);
    e = RL(e + f4(a, b, c) + _x[5] + 0x8f1bbcdc, 6) + d;
    b = RL(b, 10);
    d = RL(d + f4(e, a, b) + _x[6] + 0x8f1bbcdc, 5) + c;
    a = RL(a, 10);
    c = RL(c + f4(d, e, a) + _x[2] + 0x8f1bbcdc, 12) + b;
    e = RL(e, 10);
    
    // right
    cc = RL(cc + f2(dd, ee, aa) + _x[8] + 0x7a6d76e9, 15) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f2(cc, dd, ee) + _x[6] + 0x7a6d76e9, 5) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f2(bb, cc, dd) + _x[4] + 0x7a6d76e9, 8) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f2(aa, bb, cc) + _x[1] + 0x7a6d76e9, 11) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f2(ee, aa, bb) + _x[3] + 0x7a6d76e9, 14) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f2(dd, ee, aa) + _x[11] + 0x7a6d76e9, 14) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f2(cc, dd, ee) + _x[15] + 0x7a6d76e9, 6) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f2(bb, cc, dd) + _x[0] + 0x7a6d76e9, 14) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f2(aa, bb, cc) + _x[5] + 0x7a6d76e9, 6) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f2(ee, aa, bb) + _x[12] + 0x7a6d76e9, 9) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f2(dd, ee, aa) + _x[2] + 0x7a6d76e9, 12) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f2(cc, dd, ee) + _x[13] + 0x7a6d76e9, 9) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f2(bb, cc, dd) + _x[9] + 0x7a6d76e9, 12) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f2(aa, bb, cc) + _x[7] + 0x7a6d76e9, 5) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f2(ee, aa, bb) + _x[10] + 0x7a6d76e9, 15) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f2(dd, ee, aa) + _x[14] + 0x7a6d76e9, 8) + bb;
    ee = RL(ee, 10);
    
    //
    // Rounds 64-79
    //
    // left
    b = RL(b + f5(c, d, e) + _x[4] + 0xa953fd4e, 9) + a;
    d = RL(d, 10);
    a = RL(a + f5(b, c, d) + _x[0] + 0xa953fd4e, 15) + e;
    c = RL(c, 10);
    e = RL(e + f5(a, b, c) + _x[5] + 0xa953fd4e, 5) + d;
    b = RL(b, 10);
    d = RL(d + f5(e, a, b) + _x[9] + 0xa953fd4e, 11) + c;
    a = RL(a, 10);
    c = RL(c + f5(d, e, a) + _x[7] + 0xa953fd4e, 6) + b;
    e = RL(e, 10);
    b = RL(b + f5(c, d, e) + _x[12] + 0xa953fd4e, 8) + a;
    d = RL(d, 10);
    a = RL(a + f5(b, c, d) + _x[2] + 0xa953fd4e, 13) + e;
    c = RL(c, 10);
    e = RL(e + f5(a, b, c) + _x[10] + 0xa953fd4e, 12) + d;
    b = RL(b, 10);
    d = RL(d + f5(e, a, b) + _x[14] + 0xa953fd4e, 5) + c;
    a = RL(a, 10);
    c = RL(c + f5(d, e, a) + _x[1] + 0xa953fd4e, 12) + b;
    e = RL(e, 10);
    b = RL(b + f5(c, d, e) + _x[3] + 0xa953fd4e, 13) + a;
    d = RL(d, 10);
    a = RL(a + f5(b, c, d) + _x[8] + 0xa953fd4e, 14) + e;
    c = RL(c, 10);
    e = RL(e + f5(a, b, c) + _x[11] + 0xa953fd4e, 11) + d;
    b = RL(b, 10);
    d = RL(d + f5(e, a, b) + _x[6] + 0xa953fd4e, 8) + c;
    a = RL(a, 10);
    c = RL(c + f5(d, e, a) + _x[15] + 0xa953fd4e, 5) + b;
    e = RL(e, 10);
    b = RL(b + f5(c, d, e) + _x[13] + 0xa953fd4e, 6) + a;
    d = RL(d, 10);
    
    // right
    bb = RL(bb + f1(cc, dd, ee) + _x[12], 8) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f1(bb, cc, dd) + _x[15], 5) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f1(aa, bb, cc) + _x[10], 12) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f1(ee, aa, bb) + _x[4], 9) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f1(dd, ee, aa) + _x[1], 12) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f1(cc, dd, ee) + _x[5], 5) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f1(bb, cc, dd) + _x[8], 14) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f1(aa, bb, cc) + _x[7], 6) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f1(ee, aa, bb) + _x[6], 8) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f1(dd, ee, aa) + _x[2], 13) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f1(cc, dd, ee) + _x[13], 6) + aa;
    dd = RL(dd, 10);
    aa = RL(aa + f1(bb, cc, dd) + _x[14], 5) + ee;
    cc = RL(cc, 10);
    ee = RL(ee + f1(aa, bb, cc) + _x[0], 15) + dd;
    bb = RL(bb, 10);
    dd = RL(dd + f1(ee, aa, bb) + _x[3], 13) + cc;
    aa = RL(aa, 10);
    cc = RL(cc + f1(dd, ee, aa) + _x[9], 11) + bb;
    ee = RL(ee, 10);
    bb = RL(bb + f1(cc, dd, ee) + _x[11], 11) + aa;
    dd = RL(dd, 10);
    
    dd += c + _H1;
    _H1 = _H2 + d + ee;
    _H2 = _H3 + e + aa;
    _H3 = _H4 + a + bb;
    _H4 = _H0 + b + cc;
    _H0 = dd;
    
    //
    // reset the offset and clean out the word buffer.
    //
    _xOff = 0;
    for (int i = 0; i != 16; i++) {
        _x[i] = 0;
    }
}

@end
