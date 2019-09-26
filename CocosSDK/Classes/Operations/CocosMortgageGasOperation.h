//
//  CocosMortgageGasOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/9/25.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"

@class ChainObjectId;

NS_ASSUME_NONNULL_BEGIN

@interface CocosMortgageGasOperation : CocosBaseOperation

@property (nonatomic, strong, nonnull) ChainObjectId *mortgager;

@property (nonatomic, strong, nonnull) ChainObjectId *beneficiary;

@property (nonatomic, assign) long collateral;

@end

NS_ASSUME_NONNULL_END
