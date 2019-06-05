//
//  ChainAssetPermissionObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@interface ChainAssetPermissionObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, assign) BOOL charge_market_fee;

@property (nonatomic, assign) BOOL white_list;

@property (nonatomic, assign) BOOL override_authority;

@property (nonatomic, assign) BOOL transfer_restricted;

@property (nonatomic, assign) BOOL disable_force_settle;

@property (nonatomic, assign) BOOL global_settle;

@property (nonatomic, assign) BOOL disable_confidential;

@property (nonatomic, assign) BOOL witness_fed_asset;

@property (nonatomic, assign) BOOL committee_fed_asset;

@end
