//
//  CocosSellNHAssetCancelOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/7/9.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"
@class ChainObjectId,ChainAssetAmountObject;

NS_ASSUME_NONNULL_BEGIN

@interface CocosSellNHAssetCancelOperation : CocosBaseOperation

//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *fee_paying_account;

@property (nonatomic, strong, nonnull) ChainObjectId *order;

@property (nonatomic, strong, nonnull) NSArray *extensions;
@end

NS_ASSUME_NONNULL_END
