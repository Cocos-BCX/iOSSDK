//
//  CocosCallContractOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/3/28.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"

@class ChainObjectId,ChainValueList;
NS_ASSUME_NONNULL_BEGIN

@interface CocosCallContractOperation : CocosBaseOperation

//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *caller;

@property (nonatomic, strong, nonnull) ChainObjectId *contract_id;

@property (nonatomic, strong, nonnull) ChainAssetAmountObject *amount;

@property (nonatomic, copy, nullable) NSString *function_name;

@property (nonatomic, strong, nonnull) NSArray *value_list;

@property (nonatomic, strong, nonnull) NSArray *extensions;


@end

NS_ASSUME_NONNULL_END
