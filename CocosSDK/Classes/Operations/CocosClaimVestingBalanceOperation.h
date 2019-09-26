//
//  CocosClaimVestingBalanceOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/9/26.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"

@class ChainObjectId,ChainAssetAmountObject;

NS_ASSUME_NONNULL_BEGIN

@interface CocosClaimVestingBalanceOperation : CocosBaseOperation

@property (nonatomic, strong, nonnull) ChainObjectId *vesting_balance;

@property (nonatomic, strong, nonnull) ChainObjectId *owner;

@property (nonatomic, strong, nonnull) ChainAssetAmountObject *amount;

@end

NS_ASSUME_NONNULL_END
