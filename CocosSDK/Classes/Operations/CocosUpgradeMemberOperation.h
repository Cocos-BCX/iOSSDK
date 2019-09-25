//
//  CocosUpgradeMemberOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/7/8.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"

NS_ASSUME_NONNULL_BEGIN
@class ChainObjectId;

@interface CocosUpgradeMemberOperation : CocosBaseOperation
//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *account_to_upgrade;

@property (nonatomic, assign) BOOL upgrade_to_lifetime_member;

@property (nonatomic, strong, nonnull) NSArray *extensions;
@end

NS_ASSUME_NONNULL_END
