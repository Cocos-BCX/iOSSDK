//
//  CocosConstkey.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <UIKit/UIKit.h>

#pragma mark - API

/** 创建账户 */
UIKIT_EXTERN NSString * const kCocosCreateAccount;

// API_NONE
UIKIT_EXTERN NSString * const kCocosGetAccountByName;
UIKIT_EXTERN NSString * const kCocosGetAccounts;
UIKIT_EXTERN NSString * const kCocosGetDynamicGlobalProperties;
UIKIT_EXTERN NSString * const kCocosGetFullAccounts;
UIKIT_EXTERN NSString * const kCocosGetKeyReferences;
UIKIT_EXTERN NSString * const kCocosLookupAssetSymbols;

// API_DATABASE
UIKIT_EXTERN NSString * const kCocosGetBlock;//!< 检索完整的已签名块。-> 引用的块，如果未找到匹配的块，则返回值 null
UIKIT_EXTERN NSString * const kCocosGetBlockHeader;//!< 检索块头。 -> 引用块的标头，如果未找到匹配块，则返回值 null
UIKIT_EXTERN NSString * const kCocosGetTransactionBlock;//!<  使用该接口传入hash获取该交易的区块信息
UIKIT_EXTERN NSString * const kCocosGetLimitOrders;
UIKIT_EXTERN NSString * const kCocosGetObjects;
UIKIT_EXTERN NSString * const kCocosGetRequiredFees;
UIKIT_EXTERN NSString * const kCocosListAssets;
UIKIT_EXTERN NSString * const kCocosSetSubscribeCallback;
UIKIT_EXTERN NSString * const kCocosCancelAllSubscriptions;
UIKIT_EXTERN NSString * const kCocosLookupAccountNames;
UIKIT_EXTERN NSString * const kCocosGetAccountBalances;
UIKIT_EXTERN NSString * const kCocosGetChainId;//!< 获取链 ID。
UIKIT_EXTERN NSString * const kCocosGetContract;//!< 查询合约信息
UIKIT_EXTERN NSString * const kCocosGetTransactionById;//!< 查询合约代码
UIKIT_EXTERN NSString * const kCocosGetAccountContractData;//!< 查询账户合约信息
UIKIT_EXTERN NSString * const kCocosListAccountNHAssets;//!< 查询账户下所拥有的NH资产
UIKIT_EXTERN NSString * const kCocosLookUpNHAssets;//!< 查询NH资产详细信息
UIKIT_EXTERN NSString * const kCocosListAccountNHOrder;//!< 查询账户下的NH资产售卖单
UIKIT_EXTERN NSString * const kCocosListNHOrder;//!< 查询(购买)全网NH资产售卖单
UIKIT_EXTERN NSString * const kCocosLookUpWorldView;//!< 查询世界观详细信息
UIKIT_EXTERN NSString * const kCocosListNHbyCreator;//!< 查询开发者所创建的NH资产
UIKIT_EXTERN NSString * const kCocosSellNHAssetExpiration;//!< 查询资产售卖最大过期时间
UIKIT_EXTERN NSString * const kCocosEstimationGas;//!< 预估Gas
UIKIT_EXTERN NSString * const kCocosGetVestingBalances;//!< 查看待领取Gas或节点出块奖励

// API_HISTORY
UIKIT_EXTERN NSString * const kCocosGetAccountHistory;//!< 获取与特定帐户相关的操作。->返回 按帐户执行的操作列表，从最近到最旧排序。
UIKIT_EXTERN NSString * const kCocosGetAccountHistoryByOperations;//!< 仅获取与指定帐户相关的被询问操作。-> 按帐户执行的操作列表，从最近到最旧排序。
UIKIT_EXTERN NSString * const kCocosGetRelativeAccountHistory;//!< 获取与特定于该帐户的事件编号引用的指定帐户相关的操作。帐户的当前操作数可以在帐户统计信息中找到 (或使用 0 表示开始)。-> 按帐户执行的操作列表，从最近到最旧排序。
UIKIT_EXTERN NSString * const kCocosGetMarketHistory;//!< 获取时间范围内交易对的 OHLCV(开盘价、最高价、最低价、收盘价、交易量)数据。 -> OHLCV 数据列表，以“最近的第一个”顺序排列。如果指定时间范围内有超过 200 条记录，则返回前 200 条 记录。
UIKIT_EXTERN NSString * const kCocosGetMarketHistoryBuckets;//!< 获取此 API 服务器支持(配置)的 OHLCV 时间段长度。 -> 时间段长度列表，以秒为单位。EG 如果结果包含数字“300”，则表示此 API 服务器支持在 5 分钟里聚合的 OHLCV 数据。


// API_NETWORK_BROADCAST
UIKIT_EXTERN NSString * const kCocosNetworkBroadcast;
UIKIT_EXTERN NSString * const kCocosBroadcastTransaction;
