//
//  BitAddressAuthorityObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class CocosBitAddress;
@interface BitAddressAuthorityObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong, readonly) CocosBitAddress *address;

@property (nonatomic, assign, readonly) short weight_threshold;

- (instancetype)initWithBitAddress:(CocosBitAddress *)bitAddress weightThreshold:(short)weightThreshold;

@end
