//
//  ChainVestingBalance.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/9/26.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
#import "ChainVestingBalancePolicy.h"

@class ChainObjectId,ChainAssetAmountObject;

NS_ASSUME_NONNULL_BEGIN

@interface ChainVestingBalance : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) ChainObjectId *identifier;

@property (nonatomic, copy) NSString *describe;

@property (nonatomic, strong) ChainObjectId *owner;

@property (nonatomic, strong) ChainAssetAmountObject *balance;

@property (nonatomic, strong) NSArray *policy;

@end

NS_ASSUME_NONNULL_END
