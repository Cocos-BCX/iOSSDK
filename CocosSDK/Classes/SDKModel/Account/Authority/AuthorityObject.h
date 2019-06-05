//
//  AuthorityObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class BitAddressAuthorityObject;
@class PublicKeyAuthorityObject;
@class AccountAuthoriyObject;

@class CocosPublicKey;
@interface AuthorityObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, assign) int weight_threshold;

@property (nonatomic, copy) NSArray <AccountAuthoriyObject *>*account_auths;

@property (nonatomic, copy) NSArray <PublicKeyAuthorityObject *>*key_auths;

@property (nonatomic, copy) NSArray <BitAddressAuthorityObject *>*address_auths;

- (BOOL)containPublicKey:(CocosPublicKey *)publicKey;

- (NSArray <CocosPublicKey *> *)publicKeys;

@end
