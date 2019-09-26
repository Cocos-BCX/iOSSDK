//
//  ChainVestingBalancePolicy.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/9/26.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChainVestingBalancePolicy : NSObject<ObjectToDataProtocol>

@property (nonatomic, assign, readonly) float coin_seconds_earned;

@property (nonatomic, copy) NSString *coin_seconds_earned_last_update;

@property (nonatomic, copy) NSString *start_claim;

@property (nonatomic, assign, readonly) float vesting_seconds;
@end

NS_ASSUME_NONNULL_END
