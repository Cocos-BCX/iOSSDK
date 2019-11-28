//
//  ChainEncryptionMemo.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

@class CocosPublicKey,CocosPrivateKey;

@interface ChainEncryptionMemo : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong, readonly) CocosPublicKey *from;

@property (nonatomic, strong, readonly) CocosPublicKey *to;

@property (nonatomic, copy, readonly) NSData *message;

@property (nonatomic, copy, readonly) NSString *nonce;

- (instancetype)initWithPrivateKey:(CocosPrivateKey *)priKey anotherPublickKey:(CocosPublicKey *)anotherPubKey customerNonce:(NSString *)customerNonce totalMessage:(NSString *)totalMessage;

- (NSString *)getMessageWithPrivateKey:(CocosPrivateKey *)privateKey;

@end
