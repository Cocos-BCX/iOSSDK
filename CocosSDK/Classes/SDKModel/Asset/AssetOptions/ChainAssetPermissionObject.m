//
//  ChainAssetPermissionObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainAssetPermissionObject.h"

#import "CocosPackData.h"

@implementation ChainAssetPermissionObject



+ (instancetype)generateFromObject:(id)object {
    if (![object isKindOfClass:[NSNumber class]]) return nil;
    
    NSInteger final_permission = [object integerValue];
    
    ChainAssetPermissionObject *permission = [[ChainAssetPermissionObject alloc] init];
    
    permission.charge_market_fee = final_permission & 0x01;
    
    permission.white_list = final_permission & 0x02;
    
    permission.override_authority = final_permission & 0x04;
    
    permission.transfer_restricted = final_permission & 0x08;
    
    permission.disable_force_settle = final_permission & 0x10;
    
    permission.global_settle = final_permission & 0x20;
    
    permission.disable_confidential = final_permission & 0x40;
    
    permission.witness_fed_asset = final_permission & 0x80;
    
    permission.committee_fed_asset = final_permission & 0x100;
    
    return permission;
}

- (id)generateToTransferObject {
    NSInteger final_permission = 0;
    
    if (self.charge_market_fee) final_permission += 0x01;
    
    if (self.white_list) final_permission += 0x02;
    
    if (self.override_authority) final_permission += 0x04;
    
    if (self.transfer_restricted) final_permission += 0x08;
    
    if (self.disable_force_settle) final_permission += 0x10;
    
    if (self.global_settle) final_permission += 0x20;
    
    if (self.disable_confidential) final_permission += 0x40;
    
    if (self.witness_fed_asset) final_permission += 0x80;
    
    if (self.committee_fed_asset) final_permission += 0x100;
    
    return @(final_permission);
}

- (NSData *)transformToData {
    return [CocosPackData packShort:[[self generateToTransferObject] integerValue]];
}
@end
