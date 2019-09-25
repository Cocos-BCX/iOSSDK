//
//  CocosSellNHAssetOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/7/9.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"
@class ChainObjectId,ChainAssetAmountObject;
NS_ASSUME_NONNULL_BEGIN

@interface CocosSellNHAssetOperation : CocosBaseOperation

//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *seller;

@property (nonatomic, strong, nonnull) ChainObjectId *otcaccount;

@property (nonatomic, strong, nonnull) ChainAssetAmountObject *pending_orders_fee;

@property (nonatomic, strong, nonnull) ChainObjectId *nh_asset;

@property (nonatomic, copy, nonnull) NSString *memo;

@property (nonatomic, strong, nonnull) ChainAssetAmountObject *price;

@property (nonatomic, strong, nonnull) NSDate *expiration;

//@property (nonatomic, strong, nonnull) NSArray *extensions;

@end

NS_ASSUME_NONNULL_END
