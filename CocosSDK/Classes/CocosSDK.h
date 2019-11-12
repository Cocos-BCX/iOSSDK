//
//  CocosSDK.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import <Foundation/Foundation.h>
#import "WebsocketBlockChainApi.h"
#import "CocosHTTPManager.h"
#import "CocosDataBase+Account.h"
#import "UploadBaseModel.h"

@class CallBackModel,ChainAccountModel,ChainAssetObject,ChainMemo,CocosBaseOperation,CocosCallContractOperation;

NS_ASSUME_NONNULL_BEGIN

//@protocol CocosSDKConnectStatusDelegate <NSObject>
//
///** RPC status callback */
//- (void)Cocos_connectStatusChange:(WebsocketConnectStatus)status;
//
//@end

@interface CocosSDK : NSObject

/**
 Singleton method
 
 @return returns the provider of the SDK's method
 */
+ (instancetype)shareInstance;

/** RPC Connect Status Block */
@property (nonatomic, copy) void (^connectStatusChange)(WebsocketConnectStatus status);

/** RPC Connect delegate */
//@property (nonatomic, weak) id <CocosSDKConnectStatusDelegate> delegate;

#pragma mark - System Setup Method
/**
 *  Get SDK's version
 *  @return Current SDK's version
 */
- (NSString *)Cocos_SdkCurentVersion;

/**
 *  Open debug log
 *
 *  @param isOpen YES means open，No means close
 */
- (void)Cocos_OpenLog:(BOOL)isOpen;

#pragma mark - Init Method
/**
 Initialize SDK
 
 @param url RPC     Node
 @param faucetUrl   URL Address
 @param timeOut     Timeout
 @param coreAsset   Chain identifier
 @param chainId     Chain ID
 @param connectedStatus Status of connection
 */
- (void)Cocos_ConnectWithNodeUrl:(NSString *)url
                       Fauceturl:(NSString *)faucetUrl
                         TimeOut:(NSTimeInterval)timeOut
                       CoreAsset:(NSString *)coreAsset
                         ChainId:(NSString *)chainId
                 ConnectedStatus:(void (^)(WebsocketConnectStatus connectStatus))connectedStatus;
/**
 Query Current Chain ID
 */
- (void)Cocos_QueryCurrentChainID:(SuccessBlock)successBlock
                            Error:(Error)errorBlock;
#pragma mark - Create account
/**
 Create account
 
 @param walletMode  Mode of wallet
 @param accountName Account
 @param password    Password
 @param autoLogin   Auto log in
 */
- (void)Cocos_CreateAccountWalletMode:(CocosWalletMode)walletMode
                          AccountName:(NSString *)accountName
                             Password:(NSString *)password
                            AutoLogin:(BOOL)autoLogin
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock;
/**
 Import wallet
 
 @param private_key     Private key
 @param tempPassword    Temporary password
 */
- (void)Cocos_ImportWalletWithPrivate:(NSString *)private_key
                           WalletMode:(CocosWalletMode)walletMode
                         TempPassword:(NSString *)tempPassword
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock;
/**
 Delete wallet
 
 @param accountName Account
 */
- (void)Cocos_DeleteWalletAccountName:(NSString *)accountName
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock;

#pragma mark - Wallet mode operation
/**
 Backup wallet
 
 @param accountName Wallet name(The name must have logged in and been saved in SDK database)
 */
- (void)Cocos_BackupWalletWithAccountName:(NSString *)accountName
                                  Success:(SuccessBlock)successBlock
                                    Error:(Error)errorBlock;

/**
 Recover wallet
 
 @param keystone        Backup for recovery
 @param keystonePwd     Password for recovery
 */
- (void)Cocos_RecoverWalletWithString:(NSString *)keystone
                          KeystonePwd:(NSString *)keystonePwd
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock;
/** Get Account full info */
- (void)Cocos_GetFullAccount:(NSString *)assetIdOrName
                     Success:(SuccessBlock)successBlock
                       Error:(Error)errorBlock;

/** Get all symple wallet accounts saved in SDK */
- (NSMutableArray *)Cocos_QueryAllDBAccountInfo;

/** Get all wallet accounts saved in SDK */
- (void)Cocos_QueryAllAccountSuccess:(SuccessBlock)successBlock
                               Error:(Error)errorBlock;

#pragma mark - Account mode operation
/**
 Log in by account
 
 @param accountName Account
 @param password    Password
 */
- (void)Cocos_LoginAccountWithName:(NSString *)accountName
                          Password:(NSString *)password
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;

#pragma mark - Information Operation of Accounts
/**
 Get private key
 
 @param accountName     Account
 @param password        Password
 */
- (void)Cocos_GetPrivateWithName:(NSString *)accountName
                        Password:(NSString *)password
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock;
/**
 Get account simple object by Account
 
 @param accountName Account
 */
- (void)Cocos_GetDBAccount:(NSString *)accountName
                   Success:(SuccessBlock)successBlock
                     Error:(Error)errorBlock;
/**
 Get account object by Account
 
 @param accountIdOrName Account or Account ID(eg.@"name" or @"1.2.n")
 */
- (void)Cocos_GetAccount:(NSString *)accountIdOrName
                 Success:(SuccessBlock)successBlock
                   Error:(Error)errorBlock;
/**
 Get account's balance
 
 @param accountID Account ID
 @param coinID    Coin IDs ('@[]' will get All coin Balance, @[1.3.0] is COCOS)
 */
- (void)Cocos_GetAccountBalance:(NSString *)accountID
                         CoinID:(NSArray *)coinID
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock;

/**
 Get account history about one account
 
 @param accountID   Account ID
 @param limit       Amount
 */
- (void)Cocos_GetAccountHistory:(NSString *)accountID
                          Limit:(NSInteger)limit
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock;
/**
 Get transaction about one hash
 
 @param transferhash   hash
 
 */
- (void)Cocos_GetTransactionById:(NSString *)transferhash
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock;
/**
 Decrypt memo①
 
 @param memo        memo
 @param active_key  Active private key
 */
- (void)Cocos_DecryptMemo:(NSDictionary *)memo
                  Private:(NSString *)active_key
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock;
/**
 Decrypt memo②
 
 @param memo memo
 @param accountName Account
 @param password    Password
 */
- (void)Cocos_DecryptMemo:(NSDictionary *)memo
              AccountName:(NSString *)accountName
                 Password:(NSString *)password
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock;
/**
 Upgrade Membership
 
 @param account account
 */
- (void)Cocos_UpgradeMemberAccount:(NSString *)account
                          password:(NSString *)password
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;

#pragma mark - Asset query operation
/**
 Get blockchain assets list
 
 @param nLimit  Amount(maximum 100)
 */
- (void)Cocos_ChainListLimit:(NSInteger)nLimit
                     Success:(SuccessBlock)successBlock
                       Error:(Error)errorBlock;
/**
 Get Asset by name
 
 @param assetIdOrName Asset name or ID(@"COCOS" or @"1.3.n")
 */
- (void)Cocos_GetAsset:(NSString *)assetIdOrName
               Success:(SuccessBlock)successBlock
                 Error:(Error)errorBlock;
/**
 Get Asset object by ID[1.3.n]
 
 @param assetIds Asset ID(array)
 */
- (void)Cocos_GetAssets:(NSArray *)assetIds
                Success:(SuccessBlock)successBlock
                  Error:(Error)errorBlock;

/** Get object by IDs [eg.1.3.n] */
- (void)Cocos_GetObjects:(NSArray *)objectIds
                 Success:(SuccessBlock)successBlock
                   Error:(Error)errorBlock;
/**
 Transfer
 
 @param fromName        Sender's account
 @param toName          Receiver's account
 @param password        Password
 @param transferAsset   Asset's name(eg. COCOS)
 @param assetAmount     assetAmount Transfer amount
 @param memo            Memo String
 */
- (void)Cocos_TransferFromAccount:(NSString *)fromName
                        ToAccount:(NSString *)toName
                         Password:(NSString *)password
                    TransferAsset:(NSString *)transferAsset
                      AssetAmount:(NSString *)assetAmount
                             Memo:(NSString *)memo
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock;

/**
 Receivables (String used to generate two-dimensional receipt code)
 
 @param receiver receiver
 @param symbol Currency of transfer
 @param amount amount of transfer
 @param fee_symbol Payment of handling fees in currencies
 @param memo memo
 @param custom Custom Extension
 */
- (void)Cocos_Receivables:(NSString *)receiver
                   Symbol:(NSString *)symbol
                   Amount:(NSString *)amount
               Fee_symbol:(NSString *)fee_symbol
                     Memo:(NSString *)memo
                   Custom:(NSString *)custom
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock;
#pragma mark - Contract
/**
 Get Contract info
 
 @param contractIdOrName Contract or Contract id
 */
- (void)Cocos_GetContract:(NSString *)contractIdOrName
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock;
/**
 Get Contract Info
 
 @param current_version contract version
 */
- (void)Cocos_GetContractCreatInfo:(NSString *)current_version
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;
/**
 Get Contract Info of Account
 
 @param accountId accountId
 @param contractId contractId
 */
- (void)Cocos_GetAccountContractData:(NSString *)accountId
                          ContractId:(NSString *)contractId
                             Success:(SuccessBlock)successBlock
                               Error:(Error)errorBlock;
/**
 Call contract
 
 @param contractIdOrName      Contract name or ID
 @param param                Parameter
 @param contractmMethod     Method name
 @param accountIdOrName     Account name or id
 @param password            password
 */
- (void)Cocos_CallContract:(NSString *)contractIdOrName
       ContractMethodParam:(NSArray *)param
            ContractMethod:(NSString *)contractmMethod
             CallerAccount:(NSString *)accountIdOrName
                  Password:(NSString *)password
                   Success:(SuccessBlock)successBlock
                     Error:(Error)errorBlock;

#pragma make -NHAssets
/**
 Get NH Asset's details
 @param assetidOrhashArray NH Asset's hash or ID List
 */
- (void)Cocos_LookupNHAsset:(NSArray *)assetidOrhashArray
                    Success:(SuccessBlock)successBlock
                      Error:(Error)errorBlock;
/**
 Get account's all NH assets
 
 @param accountID        Account ID
 @param worldViewIDArray World view
 @param pageSize         pageSize
 @param page             page
 */
- (void)Cocos_ListAccountNHAsset:(NSString *)accountID
                       WorldView:(NSArray *)worldViewIDArray
                        PageSize:(NSInteger)pageSize
                            Page:(NSInteger)page
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock;
/**
 Get account's NH assets' sell list
 
 @param accountID       Account
 @param pageSize        pageSize
 @param page            page
 */
- (void)Cocos_ListAccountNHAssetOrder:(NSString *)accountID
                             PageSize:(NSInteger)pageSize
                                 Page:(NSInteger)page
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock;
/**
 Get sell list of NH assets on web
 
 @param assetID             NH assets ID
 @param worldViewIDOrName   World view ID or name
 @param baseDescribe        baseDescribe
 @param pageSize            pageSize
 @param page                page
 */
- (void)Cocos_AllListNHAssetOrder:(NSString *)assetID
                        WorldView:(NSString *)worldViewIDOrName
                     BaseDescribe:(NSString *)baseDescribe
                         PageSize:(NSInteger)pageSize
                             Page:(NSInteger)page
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock;
/**
 Get world view's details
 
 @param worldViewIDOrNameArray  World view's name or id
 */
- (void)Cocos_LookupWorldView:(NSArray *)worldViewIDOrNameArray
                      Success:(SuccessBlock)successBlock
                        Error:(Error)errorBlock;
/**
 Get NH assets that creator created
 
 @param accountID AccountID
 @param pageSize  PageSize
 @param page      Page
 */
- (void)Cocos_ListNHAssetByCreator:(NSString *)accountID
                          PageSize:(NSInteger)pageSize
                              Page:(NSInteger)page
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;

#pragma mark - NHAsset Operation
/**
 assets transfer
 
 @param from            Asset sender
 @param to              Asset receiver
 @param NHAssetID       NHAssetID
 @param password        password
 */
- (void)Cocos_TransferNHAsset:(NSString *)from
                    ToAccount:(NSString *)to
                    NHAssetID:(NSString *)NHAssetID
                     Password:(NSString *)password
                      Success:(SuccessBlock)successBlock
                        Error:(Error)errorBlock;
/**
 Buy NH assets
 
 @param orderID        NH asset order's ID
 @param account        Buyer's account
 @param password       password
 */
- (void)Cocos_BuyNHAssetOrderID:(NSString *)orderID
                        Account:(NSString *)account
                       Password:(NSString *)password
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock;
/**
 Delete NH assets
 
 @param account         account
 @param password        password
 @param nhAssetID       nhAssetID
 */
- (void)Cocos_DeleteNHAssetAccount:(NSString *)account
                          Password:(NSString *)password
                         nhAssetID:(NSString *)nhAssetID
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;
/**
 Cancel Sell NH assets
 
 @param account         account
 @param password        password
 @param orderId         orderId
 */
- (void)Cocos_CancelNHAssetAccount:(NSString *)account
                          Password:(NSString *)password
                           OrderId:(NSString *)orderId
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;
/**
 Sell NH assets
 
 @param SellerAccount 出售人账户
 @param nhAssetid nh资产id
 @param memo 备注
 @param priceAmount 价格
 @param pendingFeeAmount 挂单费用
 @param sellAsset 交易代币
 @param opAsset 操作币种
 @param expiration 过期时间(即挂卖时间,number类型,如3600，表示3600秒后过期)
 */
- (void)Cocos_SellNHAssetSeller:(NSString *)SellerAccount
                       Password:(NSString *)password
                      NHAssetId:(NSString *)nhAssetid
                           Memo:(NSString *)memo
                SellPriceAmount:(NSString *)priceAmount
               PendingFeeAmount:(NSString *)pendingFeeAmount
                 OperationAsset:(NSString *)opAsset
                      SellAsset:(NSString *)sellAsset
                     Expiration:(NSString *)expiration
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock;

/** Sell NH assets MaxExpiration */
- (void)Cocos_SellNHAssetMaxExpirationSuccess:(SuccessBlock)successBlock Error:(Error)errorBlock;

#pragma mark - Gas Mortgage and Receive
/**
 estimation gas
 
 @param amount COCOS
 */
- (void)Cocos_Gas_EstimationWithCOCOSAmout:(NSString *)amount
                                   Success:(SuccessBlock)successBlock
                                     Error:(Error)errorBlock;
/**
 mortgager gas
 
 @param mortgager mortgager
 @param beneficiary beneficiary
 @param collateral collateral
 */
- (void)Cocos_GasWithMortgager:(NSString *)mortgager
                   Beneficiary:(NSString *)beneficiary
                    Collateral:(long)collateral
                      Password:(NSString *)password
                       Success:(SuccessBlock)successBlock
                         Error:(Error)errorBlock;
/**
 lookup Block Rewards
 @param account account
 */
- (void)Cocos_QueryVestingBalance:(NSString *)account
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock;

/**
 claim vesting balance
 @param account account
 @param password password
 @param vesting_id vestingid
 */
- (void)Cocos_ClaimVestingBalance:(NSString *)account
                         Password:(NSString *)password
                        VestingID:(NSString *)vesting_id
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock;

#pragma mark - Committee Member Witnesses Vote
/** Get CommitteeMember Info: Active、Vote*/
- (void)Cocos_GetCommitteeMemberInfoVoteAccountId:(NSString *)account_id
                                          Success:(SuccessBlock)successBlock
                                            Error:(Error)errorBlock;

/** Get Witness Info: Active、Vote*/
- (void)Cocos_GetWitnessInfoVoteAccountId:(NSString *)account_id
                                  Success:(SuccessBlock)successBlock
                                    Error:(Error)errorBlock;
/**
Votes CommitteeMember , Witness
 
@param accountName accountName
@param password account password
@param type  1 -> Witness,0 -> CommitteeMember
@param voteids witnessesIds or committeeIds
@param votes votes
*/
- (void)Cocos_PublishVotes:(NSString *)accountName
                  Password:(NSString *)password
                      Type:(int)type
                  VoteIds:(NSArray *)voteids
                     Votes:(NSString *)votes
                   Success:(SuccessBlock)successBlock
                     Error:(Error)errorBlock;

/** Get global variable parameter(latest blocks news etc.) */
- (void)Cocos_GetDynamicGlobalPropertiesWithSuccess:(SuccessBlock)successBlock Error:(Error)errorBlock;

/** Get Block Header */
- (void)Cocos_GetBlockHeaderWithBlockNum:(NSNumber *)blockNum
                                 Success:(SuccessBlock)successBlock
                                   Error:(Error)errorBlock;
/** Get Transaction In Block Info  */
- (void)Cocos_GetTransactionBlockWithHash:(NSString *)tansferHash
                                  Success:(SuccessBlock)successBlock
                                    Error:(Error)errorBlock;
/** Get Block */
- (void)Cocos_GetBlockWithBlockNum:(NSNumber *)blockNum
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;

#pragma mark - Expanding Method
/**
 Expand custom api
 
 @param chainApi            Api library
 @param method              Type of method
 @param methodName          Name of method
 @param uploadParamsArray   Parameter
 */
- (void)Cocos_SendWithChainApi:(WebsocketBlockChainApi)chainApi
                        Method:(WebsocketBlockChainMethodApi)method
                    MethodName:(NSString *)methodName
                        Params:(NSArray *)uploadParamsArray
                       Success:(SuccessBlock)successBlock
                         Error:(Error)errorBlock;
@end

NS_ASSUME_NONNULL_END
