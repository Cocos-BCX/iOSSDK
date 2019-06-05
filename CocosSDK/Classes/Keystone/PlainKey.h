//
//  PlainKey.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class CocosPublicKey,CocosPrivateKey;

@interface PlainKey : NSObject<ObjectToDataProtocol>

- (instancetype)initWithCipherKey:(NSString *)cipherKey;

- (BOOL)unlockWithPassword:(NSString *)password;

- (BOOL)lockWithPassword:(NSString *)password;

- (void)addPrivateKey:(CocosPrivateKey *)privateKey;

- (CocosPrivateKey *)getPrivateKey:(CocosPublicKey *)pubKey;

- (BOOL)isNew;

@end
