//
//  CocosPCH.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#ifndef CocosPCH_h
#define CocosPCH_h

#import "CocosSetting.h"
#import "CocosConfig.h"
#import "UploadParams.h"
#import "CallBackModel.h"
#import "WebsocketClient.h"
#import "CocosConstkey.h"
#import "ChainObjectId.h"
#import "ChainEncryptionMemo.h"
#import "ChainAccountModel.h"
#import "ChainAssetObject.h"
#import "CocosTransferOperation.h"
#import "CocosCallContractOperation.h"
#import "CocosTransferNHOperation.h"
#import "CocosBuyNHOrderOperation.h"
#import "CocosCreateSonAccountOperation.h"
#import "CocosVoteOperation.h"
#import "CocosUpgradeMemberOperation.h"
#import "CocosDeleteNHOperation.h"
#import "CocosSellNHAssetCancelOperation.h"
#import "CocosSellNHAssetOperation.h"
#import "CocosMortgageGasOperation.h"
#import "CocosClaimVestingBalanceOperation.h"
#import "CocosOperationContent.h"
#import "SignedTransaction.h"
#import "AuthorityObject.h"
#import "AccountOptionObject.h"
#import "CocosPrivateKey.h"
#import "CocosPublicKey.h"
#import "NSData+Base16.h"
#import "ChainAssetAmountObject.h"
#import "ChainDynamicGlobalProperties.h"
#import "KeystoneFile.h"
#import "PublicKeyAuthorityObject.h"
#import "NSData+HashData.h"
#import "NSData+CopyWithRange.h"
#import "CocosPackData.h"
#import "ChainContract.h"
#import "ChainNHAssetOrder.h"

/** self Weak reference */
#define SDKWeakSelf __weak typeof(self) weakSelf = self;
#define SDKStrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;

/**
 *  string is nil or null or empty
 */
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))

/**
 *  object is nil or null
 */
#define IsNilOrNull(_ref)   (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) || ([(_ref) isEqual:[NSNull class]]))

#endif /* CocosPCH_h */
