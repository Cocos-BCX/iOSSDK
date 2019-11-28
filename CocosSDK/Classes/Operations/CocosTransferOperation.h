//
//  CocosTransferOperation.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosBaseOperation.h"
#import "ObjectToDataProtocol.h"

@class ChainObjectId,ChainAssetAmountObject;

@interface CocosTransferOperation : CocosBaseOperation

//@property (nonatomic, strong, nonnull) ChainAssetAmountObject *fee;

@property (nonatomic, strong, nonnull) ChainObjectId *from;

@property (nonatomic, strong, nonnull) ChainObjectId *to;

@property (nonatomic, strong, nonnull) ChainAssetAmountObject *amount;

@property (nonatomic, strong, nullable) NSArray *memo;

@property (nonatomic, strong, nonnull) NSArray *extensions;


@end
