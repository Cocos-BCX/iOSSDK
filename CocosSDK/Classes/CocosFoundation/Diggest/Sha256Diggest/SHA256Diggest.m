//
//  SHA256Diggest.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "SHA256Diggest.h"

@interface SHA256Diggest (){
    int _x[64];
}

@property (nonatomic, assign) int xOffSet;

@property (nonatomic, assign) int H1;
@property (nonatomic, assign) int H2;
@property (nonatomic, assign) int H3;
@property (nonatomic, assign) int H4;
@property (nonatomic, assign) int H5;
@property (nonatomic, assign) int H6;
@property (nonatomic, assign) int H7;
@property (nonatomic, assign) int H8;



@end

@implementation SHA256Diggest
+ (const int *)keyArray {
    static const int finals[] = {1116352408, 1899447441, -1245643825, -373957723, 961987163, 1508970993, -1841331548, -1424204075, -670586216, 310598401, 607225278, 1426881987, 1925078388, -2132889090, -1680079193, -1046744716, -459576895, -272742522, 264347078, 604807628, 770255983, 1249150122, 1555081692, 1996064986, -1740746414, -1473132947, -1341970488, -1084653625, -958395405, -710438585, 113926993, 338241895, 666307205, 773529912, 1294757372, 1396182291, 1695183700, 1986661051, -2117940946, -1838011259, -1564481375, -1474664885, -1035236496, -949202525, -778901479, -694614492, -200395387, 275423344, 430227734, 506948616, 659060556, 883997877, 958139571, 1322822218, 1537002063, 1747873779, 1955562222, 2024104815, -2067236844, -1933114872, -1866530822, -1538233109, -1090935817, -965641998};

    return finals;
}

- (void)reset {
    [super reset];
    
    _H1 = 1779033703;
    _H2 = -1150833019;
    _H3 = 1013904242;
    _H4 = -1521486534;
    _H5 = 1359893119;
    _H6 = -1694144372;
    _H7 = 528734635;
    _H8 = 1541459225;
    
    for (int i = 0; i < 64; i ++) {
        _x[i] = 0;
    }
}


- (void)processWord:(NSData *)wordData location:(int)location {
    Byte *bytes = (Byte *)wordData.bytes;
    
    int n = bytes[location] << 24;
    n |= (bytes[++location] & 255) << 16;
    n |= (bytes[++location] & 255) << 8;
    n |= bytes[++location] & 255;
    
    _x[_xOffSet] = n;
    
    if (++_xOffSet == 16) {
        [self processBlock];
    }
}

- (void)processLength:(long)bitlength {
    if (_xOffSet > 14) {
        [self processBlock];
    }
    
    _x[14] = (int)(bitlength >> 32);
    _x[15] = (int)(bitlength & -1L);
}

- (void)processBlock {
    
    
    for (int a = 16; a <= 63; ++a) {
        _x[a] = [self Theta1WithX:_x[a - 2]] + _x[a-7] + [self Theta0WithX:_x[a - 15]] + _x[a - 16];
    }
    
    
    int a = _H1,b = _H2,c = _H3,d = _H4,e = _H5,f = _H6,g = _H7,h = _H8,t = 0;
    
    for (int i = 0; i < 8; ++i) {
        h += [self Sum1WithX:e] + [self ChWithX:e y:f z:g] + [SHA256Diggest keyArray][t] + _x[t];
        d += h;
        h += [self Sum0WithX:(a)] + [self MajWithX:a y:b z:c];
        ++t;
        
        g += [self Sum1WithX:(d)] + [self ChWithX:d y:e z:f] + [SHA256Diggest keyArray][t] + _x[t];
        c += g;
        g += [self Sum0WithX:(h)] + [self MajWithX:h y:a z:b];
        ++t;
        
        f += [self Sum1WithX:(c)] + [self ChWithX:c y:d z:e] + [SHA256Diggest keyArray][t] + _x[t];
        b += f;
        f += [self Sum0WithX:(g)] + [self MajWithX:g y:h z:a];
        ++t;
        
        e += [self Sum1WithX:(b)] + [self ChWithX:b y:c z:d] + [SHA256Diggest keyArray][t] + _x[t];
        a += e;
        e += [self Sum0WithX:(f)] + [self MajWithX:f y:g z:h];
        ++t;
        
        d += [self Sum1WithX:(a)] + [self ChWithX:a y:b z:c] + [SHA256Diggest keyArray][t] + _x[t];
        h += d;
        d += [self Sum0WithX:(e)] + [self MajWithX:e y:f z:g];
        ++t;
        
        c += [self Sum1WithX:(h)] + [self ChWithX:h y:a z:b] + [SHA256Diggest keyArray][t] + _x[t];
        g += c;
        c += [self Sum0WithX:(d)] + [self MajWithX:d y:e z:f];
        ++t;
        
        b += [self Sum1WithX:(g)] + [self ChWithX:g y:h z:a] + [SHA256Diggest keyArray][t] + _x[t];
        f += b;
        b += [self Sum0WithX:(c)] + [self MajWithX:c y:d z:e];
        ++t;
        
        a += [self Sum1WithX:(f)] + [self ChWithX:f y:g z:h] + [SHA256Diggest keyArray][t] + _x[t];
        e += a;
        a += [self Sum0WithX:(b)] + [self MajWithX:b y:c z:d];
        ++t;
    }
    
    _H1 += a;
    _H2 += b;
    _H3 += c;
    _H4 += d;
    _H5 += e;
    _H6 += f;
    _H7 += g;
    _H8 += h;
    
    _xOffSet = 0;
    
    for (int i = 0; i < 64; i ++) {
        _x[i] = 0;
    }
}

- (int)doFinalWithByteData:(Byte *)byteData outOffSet:(int)outOffSet {
    [self finish];
    void (^intToBigEndian) (int,Byte *,int) = ^(int n,Byte *byteData,int off) {
        byteData[off] = (Byte)((unsigned int)n >> 24);
        ++off;
        byteData[off] = (Byte)((unsigned int)n >> 16);
        ++off;
        byteData[off] = (Byte)((unsigned int)n >> 8);
        ++off;
        byteData[off] = (Byte)n;
    };
    
    intToBigEndian(_H1,byteData,outOffSet);
    intToBigEndian(_H2,byteData,outOffSet + 4);
    intToBigEndian(_H3,byteData,outOffSet + 8);
    intToBigEndian(_H4,byteData,outOffSet + 12);
    intToBigEndian(_H5,byteData,outOffSet + 16);
    intToBigEndian(_H6,byteData,outOffSet + 20);
    intToBigEndian(_H7,byteData,outOffSet + 24);
    intToBigEndian(_H8,byteData,outOffSet + 28);
    
    [self reset];
    
    return 32;
}

- (int)ChWithX:(int)x y:(int)y z:(int)z {
    return (x & y) ^ (~x & z);
}

- (int)MajWithX:(int)x y:(int)y z:(int)z {
    return (x & y) ^ (x & z) ^ (y & z);
}

- (int)Sum0WithX:(int)x {
    return (((unsigned int)x >> 2) | (x << 30)) ^ (((unsigned int)x >> 13) | (x << 19)) ^ (((unsigned int)x >> 22) | (x << 10));
}

- (int)Sum1WithX:(int)x {
    return (((unsigned int)x >> 6) | (x << 26)) ^ (((unsigned int)x >> 11) | (x << 21)) ^ (((unsigned int)x >> 25) | (x << 7));
}

- (int)Theta0WithX:(int)x {
    return (((unsigned int)x >> 7) | (x << 25)) ^ (((unsigned int)x >> 18) | (x << 14)) ^ ((unsigned int)x >> 3);
}

- (int)Theta1WithX:(int)x {
    return (((unsigned int)x >> 17) | (x << 15)) ^ (((unsigned int)x >> 19) | (x << 13)) ^ ((unsigned int)x >> 10);
}

@end
