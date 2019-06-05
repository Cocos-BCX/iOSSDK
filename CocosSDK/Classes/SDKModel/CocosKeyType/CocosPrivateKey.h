//
//  CocosPrivateKey.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
@class CocosPublicKey;
@interface CocosPrivateKey : NSObject

- (instancetype)initWithPrivateKey:(NSString *)privateKey;

- (CocosPublicKey *)publicKey;

- (NSString *)signedCompact:(NSData *)sha256Data requireCanonical:(BOOL)requireCanonical;

- (NSData *)getSharedSecret:(CocosPublicKey *)otherPublic;

@end
