//
//  ChainPrice.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

@class ChainAssetAmountObject;
@interface ChainPrice : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) ChainAssetAmountObject *base;

@property (nonatomic, strong) ChainAssetAmountObject *quote;

@end
