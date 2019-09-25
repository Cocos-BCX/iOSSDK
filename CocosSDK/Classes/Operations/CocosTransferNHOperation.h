//
//  CocosTransferNHOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/4/24.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"
#import "ObjectToDataProtocol.h"

@class ChainObjectId,ChainAssetAmountObject;

NS_ASSUME_NONNULL_BEGIN

@interface CocosTransferNHOperation : CocosBaseOperation

//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *from;

@property (nonatomic, strong, nonnull) ChainObjectId *to;

@property (nonatomic, strong, nonnull) ChainObjectId *nh_asset;

@end

NS_ASSUME_NONNULL_END
