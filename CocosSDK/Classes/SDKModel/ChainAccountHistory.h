//
//  ChainAccountHistory.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/21.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class ChainObjectId;

@interface ChainAccountHistory : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) ChainObjectId *identifier;

@property (nonatomic, strong) NSArray *op;

@property (nonatomic, strong) NSArray *result;

@property (nonatomic, strong) NSDecimalNumber *block_number;

@property (nonatomic, strong) NSDecimalNumber *trx_in_block;

@property (nonatomic, strong) NSDecimalNumber *op_in_trx;

@property (nonatomic, strong) NSDecimalNumber *virtual_op;

@end
