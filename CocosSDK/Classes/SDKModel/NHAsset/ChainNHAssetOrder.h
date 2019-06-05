//
//  ChainNHAssetOrder.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/4/24.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

@class ChainObjectId,ChainAssetAmountObject;
NS_ASSUME_NONNULL_BEGIN

@interface ChainNHAssetOrder : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) ChainObjectId *identifier;

@property (nonatomic, strong) ChainObjectId *seller;

@property (nonatomic, strong) ChainObjectId *otcaccount;

@property (nonatomic, strong) ChainObjectId *nh_asset_id;

@property (nonatomic, copy) NSString *asset_qualifier;

@property (nonatomic, copy) NSString *world_view;

@property (nonatomic, copy) NSString *base_describe;

@property (nonatomic, copy) NSString *nh_hash;

@property (nonatomic, strong) ChainAssetAmountObject *price;

@property (nonatomic, copy) NSString *memo;

@property (nonatomic, copy) NSString *expiration;
@end

NS_ASSUME_NONNULL_END
