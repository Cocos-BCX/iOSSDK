//
//  CocosVoteOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/10/15.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"
#import "VoteOptionsObject.h"

@class ChainAssetAmountObject,ChainObjectId;

NS_ASSUME_NONNULL_BEGIN

@interface CocosVoteOperation : CocosBaseOperation

@property (nonatomic, strong, nonnull) ChainAssetAmountObject *lock_with_vote;

@property (nonatomic, strong, nonnull) ChainObjectId *account;

@property (nonatomic, strong, nonnull) VoteOptionsObject *options;

@property (nonatomic, strong, nonnull) NSArray *extensions;

@end

NS_ASSUME_NONNULL_END
