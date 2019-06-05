//
//  ChainContract.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/4/16.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

@class ChainObjectId;

NS_ASSUME_NONNULL_BEGIN

@interface ChainContract : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) ChainObjectId *identifier;

@property (nonatomic, copy) NSString *creation_date;

@property (nonatomic, strong) ChainObjectId *owner;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *current_version;

@property (nonatomic, copy) NSString *contract_authority;

@property (nonatomic, assign) BOOL check_contract_authority;
@end

NS_ASSUME_NONNULL_END
