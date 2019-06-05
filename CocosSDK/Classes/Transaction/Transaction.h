//
//  Transaction.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "CocosOperationContent.h"
#import "ObjectToDataProtocol.h"
@interface Transaction : NSObject<ObjectToDataProtocol>

@property (nonatomic, assign, readonly) uint16_t ref_block_num;

@property (nonatomic, assign, readonly) uint32_t ref_block_prefix;

@property (nonatomic, strong) NSDate *expiration;

@property (nonatomic, copy) NSArray <CocosOperationContent *>*operations;

@property (nonatomic, strong) NSArray *extensions;

- (void)setRefBlock:(NSString *)refBlock;

@end
