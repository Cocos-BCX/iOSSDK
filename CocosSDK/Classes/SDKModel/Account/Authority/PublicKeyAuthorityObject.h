//
//  KeyAuthorityObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class CocosPublicKey;
@interface PublicKeyAuthorityObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong, readonly) CocosPublicKey *key;

@property (nonatomic, assign, readonly) short weight_threshold;

- (instancetype)initWithPublicKey:(CocosPublicKey *)publicKey weightThreshold:(short)weightThreshold;

@end
