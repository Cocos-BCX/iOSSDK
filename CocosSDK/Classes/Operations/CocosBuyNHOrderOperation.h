//
//  CocosBuyNHOrderOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/4/24.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"
#import "ObjectToDataProtocol.h"

@class ChainObjectId,ChainAssetAmountObject;

NS_ASSUME_NONNULL_BEGIN

@interface CocosBuyNHOrderOperation : CocosBaseOperation

//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *fee_paying_account;

@property (nonatomic, strong, nonnull) ChainObjectId *seller;

@property (nonatomic, strong, nonnull) ChainObjectId *order;

@property (nonatomic, strong, nonnull) ChainObjectId *nh_asset;

@property (nonatomic, copy, nonnull) NSString *price_amount;

@property (nonatomic, strong, nonnull) ChainObjectId *price_asset_id;

@property (nonatomic, copy, nonnull) NSString *price_asset_symbol;

@property (nonatomic, strong, nonnull) NSArray *extensions;
@end

NS_ASSUME_NONNULL_END
