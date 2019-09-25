//
//  CocosDeleteNHOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/7/8.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"

@class ChainObjectId;

NS_ASSUME_NONNULL_BEGIN

@interface CocosDeleteNHOperation : CocosBaseOperation

//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *fee_paying_account;

@property (nonatomic, strong, nonnull) ChainObjectId *nh_asset;

@end

NS_ASSUME_NONNULL_END
