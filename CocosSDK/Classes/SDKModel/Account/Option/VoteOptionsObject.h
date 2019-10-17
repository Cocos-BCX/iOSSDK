//
//  VoteOptionsObject.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/10/15.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class CocosPublicKey;

@interface VoteOptionsObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong, nonnull) CocosPublicKey *memo_key;

@property (nonatomic, strong, nonnull) NSArray *votes;

@property (nonatomic, strong, nonnull) NSArray *extensions;

@end

NS_ASSUME_NONNULL_END
