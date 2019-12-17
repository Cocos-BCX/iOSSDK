//
//  CocosVoteOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/10/15.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"
#import "VoteOptionsObject.h"

@class ChainAssetAmountObject,ChainObjectId,AuthorityObject;

NS_ASSUME_NONNULL_BEGIN

@interface CocosUpdateAccountOperation : CocosBaseOperation

@property (nonatomic, strong) NSArray *lock_with_vote;

@property (nonatomic, strong, nonnull) ChainObjectId *account;

@property (nonatomic, strong, nonnull) AuthorityObject *owner;

@property (nonatomic, strong) AuthorityObject *active;

@property (nonatomic, strong) VoteOptionsObject *options;

@property (nonatomic, strong, nonnull) NSArray *extensions;

@end

NS_ASSUME_NONNULL_END
