//
//  CocosConstkey.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosConstkey.h"

#pragma mark - API
/** 创建账户 */
NSString * const kCocosCreateAccount = @"/api/v1/accounts";
// API_NONE = 0x00;
NSString * const kCocosGetAccountByName = @"get_account_by_name";
NSString * const kCocosGetAccounts = @"get_accounts";
NSString * const kCocosGetDynamicGlobalProperties = @"get_dynamic_global_properties";
NSString * const kCocosGetFullAccounts = @"get_full_accounts";
NSString * const kCocosGetKeyReferences = @"get_key_references";
NSString * const kCocosLookupAssetSymbols = @"lookup_asset_symbols";

// API_DATABASE = 0x01;
NSString * const kCocosGetBlock = @"get_block";
NSString * const kCocosGetBlockHeader = @"get_block_header";
NSString * const kCocosGetTransactionBlock = @"get_transaction_in_block_info";
NSString * const kCocosGetLimitOrders = @"get_limit_orders";
NSString * const kCocosGetObjects = @"get_objects";
NSString * const kCocosGetRequiredFees = @"get_required_fees";
NSString * const kCocosListAssets = @"list_assets";
NSString * const kCocosSetSubscribeCallback = @"set_subscribe_callback";
NSString * const kCocosCancelAllSubscriptions = @"cancel_all_subscriptions";
NSString * const kCocosLookupAccountNames = @"lookup_account_names";
NSString * const kCocosGetAccountBalances = @"get_account_balances";
NSString * const kCocosGetChainId = @"get_chain_id";
NSString * const kCocosGetContract = @"get_contract";
NSString * const kCocosGetTransactionById = @"get_transaction_by_id";
NSString * const kCocosGetAccountContractData = @"get_account_contract_data";
NSString * const kCocosListAccountNHAssets = @"list_account_nh_asset";
NSString * const kCocosLookUpNHAssets = @"lookup_nh_asset";
NSString * const kCocosListAccountNHOrder = @"list_account_nh_asset_order";
NSString * const kCocosListNHOrder = @"list_nh_asset_order";
NSString * const kCocosLookUpWorldView = @"lookup_world_view";
NSString * const kCocosListNHbyCreator = @"list_nh_asset_by_creator";
NSString * const kCocosSellNHAssetExpiration= @"get_global_properties";
NSString * const kCocosEstimationGas = @"estimation_gas";
NSString * const kCocosGetVestingBalances = @"get_vesting_balances";

// API_HISTORY = 0x02;
NSString * const kCocosGetAccountHistory = @"get_account_history";
NSString * const kCocosGetAccountHistoryByOperations = @"get_account_history_operations";
NSString * const kCocosGetRelativeAccountHistory = @"get_relative_account_history";
NSString * const kCocosGetMarketHistory = @"get_market_history";
NSString * const kCocosGetMarketHistoryBuckets = @"get_market_history_buckets";

// API_NETWORK_BROADCAST = 0x04;
NSString * const kCocosNetworkBroadcast = @"network_broadcast";
NSString * const kCocosBroadcastTransaction = @"broadcast_transaction";
