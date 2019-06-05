//
//  ChainAssetOption.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
#import "ChainAssetPermissionObject.h"
@class ChainPrice;
@class ChainObjectId;
@interface ChainAssetOption : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) NSDecimalNumber *max_supply;

@property (nonatomic, assign) NSInteger market_fee_percent;

@property (nonatomic, assign) NSInteger max_market_fee;

@property (nonatomic, strong) ChainAssetPermissionObject *issuer_permissions;

@property (nonatomic, strong) ChainAssetPermissionObject *flags;

@property (nonatomic, strong) ChainPrice *core_exchange_rate;

@property (nonatomic, copy) NSArray <ChainObjectId *>*whitelist_authorities;

@property (nonatomic, copy) NSArray <ChainObjectId *>*blacklist_authorities;

@property (nonatomic, copy) NSArray <ChainObjectId *>*whitelist_markets;

@property (nonatomic, copy) NSArray <ChainObjectId *>*blacklist_markets;

@property (nonatomic, copy) NSString *descriptions;

@property (nonatomic, copy) NSArray *extensions;

@end
