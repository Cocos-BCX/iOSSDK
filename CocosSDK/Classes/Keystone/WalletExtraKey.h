//
//  WalletExtraKey.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

@class ChainObjectId,CocosPublicKey;
@interface WalletExtraKey : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) ChainObjectId *keyId;

@property (nonatomic, copy) NSArray <CocosPublicKey *>*keyArray;

- (BOOL)containPublicKey:(CocosPublicKey *)publicKey;

@end
