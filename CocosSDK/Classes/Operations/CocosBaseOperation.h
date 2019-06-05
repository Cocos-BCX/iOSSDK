//
//  CocosBaseOperation.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class CocosPublicKey;
@class ChainAssetAmountObject;
@class ChainAssetObject;
@interface CocosBaseOperation : NSObject<ObjectToDataProtocol>

/** Signature public key required for operation */
@property (nonatomic, strong) NSArray <CocosPublicKey *> *requiredAuthority;

@end
