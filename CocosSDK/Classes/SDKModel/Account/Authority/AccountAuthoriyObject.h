//
//  AccountAuthoriyObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class ChainObjectId;
@interface AccountAuthoriyObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong, readonly) ChainObjectId *accountId;

@property (nonatomic, assign, readonly) short weight_threshold;

- (instancetype)initWithAccountId:(ChainObjectId *)accountId weightThreshold:(short)weightThreshold;

@end
