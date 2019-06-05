//
//  Sha256.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/4.
//

#import <Foundation/Foundation.h>

@interface Sha256 : NSObject
@property(nonatomic, strong) NSData *mHashBytesData;
// sha256result with hex encoding 
@property(nonatomic, strong) NSString *sha256;
- (instancetype)initWithData:(NSData *)bytesData;

@end
