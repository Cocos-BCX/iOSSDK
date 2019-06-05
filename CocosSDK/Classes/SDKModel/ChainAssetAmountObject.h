//
//  ChainAssetAmountObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class ChainObjectId;

@interface ChainAssetAmountObject : NSObject<ObjectToDataProtocol>

/** AssetAmount id */
@property (nonatomic, strong, readonly) ChainObjectId *assetId;

@property (nonatomic, assign, readonly) long amount;

- (instancetype)initFromAssetId:(ChainObjectId *)objectId amount:(long)amount;



@end
