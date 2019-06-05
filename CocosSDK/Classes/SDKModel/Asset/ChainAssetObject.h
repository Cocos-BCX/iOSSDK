//
//  ChainAssetObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
#import "ChainAssetOption.h"

@class ChainObjectId;
@class ChainAssetAmountObject;
@interface ChainAssetObject : NSObject<ObjectToDataProtocol>

/** 见证 ID */
@property (nonatomic, strong) ChainObjectId *identifier;
/** 代币符号 */
@property (nonatomic, copy) NSString *symbol;
/** 精度 */
@property (nonatomic, assign) NSInteger precision;
/** 发行者 */
@property (nonatomic, strong) ChainObjectId *issuer;
/** 类型 */
@property (nonatomic, strong) ChainAssetOption *options;

@property (nonatomic, strong) ChainObjectId *dynamic_asset_data_id;

@property (nonatomic, strong) ChainObjectId *bitasset_data_id;

- (BOOL)isBitAsset;

- (ChainAssetAmountObject *)getAmountFromNormalFloatString:(NSString *)string;

- (NSString *)getRealAmountFromAssetAmount:(ChainAssetAmountObject *)assetAmount;

@end
