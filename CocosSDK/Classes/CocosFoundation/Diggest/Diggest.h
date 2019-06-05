//
//  Diggest.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>

@interface Diggest : NSObject{
    Byte _xBuf[4];
}

@property (nonatomic, assign, readonly) int xBufOff;

@property (nonatomic, assign, readonly) int byteCount;

- (int)doFinalWithByteData:(Byte *)byteData outOffSet:(int)outOffSet;

- (void)reset;

- (void)updateWithByte:(Byte)byte;

- (void)updateWithInData:(NSData *)inData range:(NSRange)range;

- (void)finish;

- (void)processLength:(long)bitlength;

- (void)processWord:(NSData *)wordData location:(int)location;

- (void)processBlock;

@end
