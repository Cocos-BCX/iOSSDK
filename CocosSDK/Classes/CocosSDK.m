//
//  CocosSDK.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import "CocosSDK.h"
#import "CocosPCH.h"

#import "Cocos_Key_Account.h"
#import "Sha256.h"
#import "CocosHTTPManager+CreateAccount.h"

@interface CocosSDK ()

@property (nonatomic, strong) WebsocketClient *client;

@end

@implementation CocosSDK
/** Singleton method */
+ (instancetype)shareInstance
{
    static CocosSDK *cocosInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cocosInstance = [[self alloc] init];
    });
    return cocosInstance;
}

#pragma mark - System Setup Method
/** Get SDK's version */
- (NSString *)Cocos_SdkCurentVersion
{
    return @"1.0.1";
}

/** Open debug log */
- (void)Cocos_OpenLog:(BOOL)isOpen;
{
    cocos_setLogEable(isOpen);
}

#pragma mark - Init Method

/** Initialize SDK */
- (void)Cocos_ConnectWithNodeUrl:(NSString *)url
                       Fauceturl:(NSString *)faucetUrl
                         TimeOut:(NSTimeInterval)timeOut
                       CoreAsset:(NSString *)coreAsset
                         ChainId:(NSString *)chainId
                 ConnectedStatus:(void (^)(WebsocketConnectStatus connectStatus))connectedStatus

{
    //    if (_client.connectStatus == WebsocketConnectStatusConnected) return;
    self.client = [[WebsocketClient alloc] initWithUrl:url closedCallBack:nil];
    [self.client connectWithTimeOut:timeOut];
    // Connection state callback
    self.client.connectStatusChange = connectedStatus;
    [CocosConfig setPrefix:coreAsset];
    [CocosConfig setChainId:chainId];
    [CocosConfig setFaucetUrl:faucetUrl];
}

- (void)setConnectStatusChange:(void (^)(WebsocketConnectStatus))connectStatusChange {
    _connectStatusChange = connectStatusChange;
    if (_client) {
        _client.connectStatusChange = connectStatusChange;
    }
}

- (void)setClient:(WebsocketClient *)client {
    _client = client;
    if (_connectStatusChange) {
        _client.connectStatusChange = _connectStatusChange;
    }
}

#pragma mark - Create account
/** Create account */
- (void)Cocos_CreateAccountWalletMode:(CocosWalletMode)walletMode
                          AccountName:(NSString *)accountName
                             Password:(NSString *)password
                            AutoLogin:(BOOL)autoLogin
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    // 1.1 Validation parameters
    if (IsStrEmpty(accountName) || IsStrEmpty(password)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ or ‘password‘  is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 1.2 Verify Account Name
    if (![self regexAccountNameValidate:accountName]) {
        NSError *error = [NSError errorWithDomain:@"Please enter the correct account name(/^a-z{4,63}/$)" code:SDKErrorCodeAccountNameError userInfo:@{@"account":accountName}];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    NSString *owner_key;
    NSString *active_key;
    NSString *owner_pubkey;
    NSString *active_pubkey;
    // 2. Generating parameters
    if (walletMode == CocosWalletModeWallet) {
        NSString *ownerSeed = [Cocos_Key_Account getRandomSeed];
        NSString *activeSeed = [Cocos_Key_Account getRandomSeed];
        owner_key = [Cocos_Key_Account private_with_seed:ownerSeed];
        active_key = [Cocos_Key_Account private_with_seed:activeSeed];
        owner_pubkey = [Cocos_Key_Account publicKey_with_seed:ownerSeed];
        active_pubkey = [Cocos_Key_Account publicKey_with_seed:activeSeed];
    }else if(walletMode == CocosWalletModeAccount){
        NSString *owner = @"owner";
        NSString *active = @"active";
        NSString *ownerSeed = [NSString stringWithFormat:@"%@%@%@",accountName,owner,password];
        NSString *activeSeed = [NSString stringWithFormat:@"%@%@%@",accountName,active,password];
        owner_key = [Cocos_Key_Account private_with_seed:ownerSeed];
        active_key = [Cocos_Key_Account private_with_seed:activeSeed];
        owner_pubkey = [Cocos_Key_Account publicKey_with_seed:ownerSeed];
        active_pubkey = [Cocos_Key_Account publicKey_with_seed:activeSeed];
    }
    // 3. Register
    [[CocosHTTPManager CCW_shareHTTPManager] Cocos_CreateAccountWithName:accountName owner_key:owner_pubkey memo_key:active_pubkey active_key:active_pubkey Success:^(NSDictionary *creatResponseObject) {
        // 4.1 Determine whether to log in automatically
        if (autoLogin) {
            // 4.2 Save account information
            [self SaveAccountInfo:accountName isNewAccount:YES OwnerPrivate:owner_key ActivePrivate:active_key Password:password WalletMode:walletMode Success:nil Error:errorBlock];
        }
        if ([creatResponseObject[@"code"] integerValue] == 200) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:creatResponseObject[@"data"][@"account"]];
            dic[@"active_pri_key"] = active_key;
            dic[@"owner_pri_key"] = owner_key;
            !successBlock?:successBlock(dic);
        }else{
            NSError *error = [NSError errorWithDomain:@"creat account error" code:SDKErrorCodeErrorNotKnown userInfo:nil];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/** Import wallet */
- (void)Cocos_ImportWalletWithPrivate:(NSString *)private_key
                           WalletMode:(CocosWalletMode)walletMode
                         TempPassword:(NSString *)tempPassword
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    // 1.Validation parameters
    if (IsStrEmpty(private_key) || IsStrEmpty(tempPassword)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘private‘ or ‘tempPassword‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 1. Judging Private Key Format
    BOOL priAvailable = [Cocos_Key_Account validateWif:private_key];
    if (priAvailable) {
        NSString *publicKey = [Cocos_Key_Account cocos_publicKey_with_wif:private_key];
        // 2. If the login is successful
        [self getKeyReferences:publicKey Success:^(NSArray *responseObject) {
            NSArray *result = responseObject.firstObject;
            if (result.count) {
                if (walletMode == CocosWalletModeAccount) {
                    // 3. Verify pass, query account information and save
                    [self SaveAccountInfo:[result firstObject] isNewAccount:NO OwnerPrivate:nil ActivePrivate:private_key Password:tempPassword WalletMode:walletMode Success:successBlock Error:errorBlock];
                }else if (walletMode == CocosWalletModeWallet){
                    NSMutableOrderedSet *mutableOrderedSet = [NSMutableOrderedSet new];
                    for (NSString *str in result) {
                        [mutableOrderedSet addObject:str];
                    }
                    for (NSString *accountID in mutableOrderedSet.array) {
                        [self SaveAccountInfo:accountID isNewAccount:NO OwnerPrivate:nil ActivePrivate:private_key Password:tempPassword WalletMode:walletMode Success:successBlock Error:errorBlock];
                    }
                }
            }else{
                // 3. The private key has no account information
                NSError *error = [NSError errorWithDomain:@"The private key has no account information" code:SDKErrorCodePrivateNoAccount userInfo:@{@"key":private_key}];
                !errorBlock?:errorBlock(error);
            }
        } Error:errorBlock];
    }else{
        NSError *error = [NSError errorWithDomain:@"Please enter the correct private key" code:SDKErrorCodePrivateError userInfo:@{@"key":private_key}];
        !errorBlock?:errorBlock(error);
    }
}

/** Delete wallet */
- (void)Cocos_DeleteWalletAccountName:(NSString *)accountName
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountName)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 2. Query database user information
    CocosDBAccountModel *dbWallet = [[CocosDataBase Cocos_shareDatabase] Cocos_QueryMyAccountWithName:accountName addChainId:[CocosConfig chainId]];
    if (dbWallet.name == nil) {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ not found",accountName] code:SDKErrorCodeAccountNotFound userInfo:@{@"account":accountName}];
        !errorBlock?:errorBlock(error);;
        return;
    }
    // 3. Query the user and delete
    [[CocosDataBase Cocos_shareDatabase] Cocos_DeleteAccountWithName:dbWallet.name addChainId:[CocosConfig chainId]];
    !successBlock?:successBlock(@"success");
}

#pragma mark - Wallet mode operation
/** Backup wallet */
- (void)Cocos_BackupWalletWithAccountName:(NSString *)accountName
                                  Success:(SuccessBlock)successBlock
                                    Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountName)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 2. Query database user information
    CocosDBAccountModel *dbWallet = [[CocosDataBase Cocos_shareDatabase] Cocos_QueryMyAccountWithName:accountName addChainId:[CocosConfig chainId]];
    if (dbWallet.name == nil) {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ not found",accountName] code:SDKErrorCodeAccountNotFound userInfo:@{@"account":accountName}];
        !errorBlock?:errorBlock(error);;
        return;
    }
    
    // 3. Query the user and callback
    !successBlock?:successBlock(dbWallet.keystone);
}

/** Recover wallet */
- (void)Cocos_RecoverWalletWithString:(NSString *)keystone
                          KeystonePwd:(NSString *)keystonePwd
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    [self DecryptKeyStone:keystone KeystonePwd:keystonePwd SaveAccountInfo:YES Success:successBlock Error:errorBlock];
}
/** Get all symple wallet accounts saved in SDK */
- (NSMutableArray *)Cocos_QueryAllDBAccountInfo
{
    return [[CocosDataBase Cocos_shareDatabase] Cocos_QueryMyAllAccountWithChainId:[CocosConfig chainId]];
}

/** Get Account full info */
- (void)Cocos_GetFullAccount:(NSString *)assetIdOrName
                     Success:(SuccessBlock)successBlock
                       Error:(Error)errorBlock
{
    // 1. Query all wallet accounts in the database
    
    // 2. Request account information with all wallet account IDs
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosGetFullAccounts;
    uploadParams.totalParams = @[@[assetIdOrName],@(NO)];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Get all wallet accounts saved in SDK */
- (void)Cocos_QueryAllAccountSuccess:(SuccessBlock)successBlock
                               Error:(Error)errorBlock
{
    // 1. Query all wallet accounts in the database
    NSMutableArray *allAccountName = [[CocosDataBase Cocos_shareDatabase] Cocos_QueryMyAllAccountNameWithChainId:[CocosConfig chainId]];
    
    // 2. Request account information with all wallet account IDs
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosGetFullAccounts;
    uploadParams.totalParams = @[allAccountName,@(NO)];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

#pragma mark - Account mode operation
/** Log in by account */
- (void)Cocos_LoginAccountWithName:(NSString *)accountName
                          Password:(NSString *)password
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountName) || IsStrEmpty(password)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ or ‘password‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 2. Generate public key
    NSString *active = @"active";
    NSString *owner = @"owner";
    NSString *ownerSeed = [NSString stringWithFormat:@"%@%@%@",accountName,owner,password];
    NSString *activeSeed = [NSString stringWithFormat:@"%@%@%@",accountName,active,password];
    NSString *owner_pubkey = [Cocos_Key_Account publicKey_with_seed:ownerSeed];
    //    NSString *active_pubkey = [Cocos_Key_Account publicKey_with_seed:activeSeed];
    
    // 3. Authenticate Account Public Key (Logon Authentication)
    [self getKeyReferences:owner_pubkey Success:^(NSArray *responseObject) {
        NSArray *result = responseObject.firstObject;
        if (result.count) {
            // 4. Authentication passes, encryption saves
            NSString *owner_key = [Cocos_Key_Account private_with_seed:ownerSeed];
            NSString *active_key = [Cocos_Key_Account private_with_seed:activeSeed];
            [self SaveAccountInfo:[result firstObject] isNewAccount:NO OwnerPrivate:owner_key ActivePrivate:active_key Password:password WalletMode:CocosWalletModeAccount Success:successBlock Error:errorBlock];
        }else{
            NSError *error = [NSError errorWithDomain:@"User name or password error (please confirm that your account is registered in account mode, and the account registered in wallet mode cannot be logged in using account mode)" code:SDKErrorCodeAccountNameOrPasswordError userInfo:@{@"account":accountName,@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

#pragma mark - Information Operation of Accounts
/** Get private key */
- (void)Cocos_GetPrivateWithName:(NSString *)accountName
                        Password:(NSString *)password
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountName) || IsStrEmpty(password)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 2. Database Query User Information
    CocosDBAccountModel *dbWallet = [[CocosDataBase Cocos_shareDatabase] Cocos_QueryMyAccountWithName:accountName addChainId:[CocosConfig chainId]];
    if (dbWallet.name == nil) {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ not found",accountName] code:SDKErrorCodeAccountNotFound userInfo:@{@"account":accountName}];
        !errorBlock?:errorBlock(error);;
        return;
    }
    
    // 3. Query user information and parse Keystone
    NSDictionary *keystoneDic = [NSJSONSerialization JSONObjectWithData:[dbWallet.keystone dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingAllowFragments) error:nil];
    if (!keystoneDic) {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ not found",accountName] code:SDKErrorCodeAccountNotFound userInfo:@{@"account":accountName}];
        !errorBlock?:errorBlock(error);;
        return;
    }
    // 4. Decrypt keystone
    [self DecryptKeyStone:dbWallet.keystone KeystonePwd:password SaveAccountInfo:NO Success:successBlock Error:errorBlock];
}
/**
 Get account simple object by Account
 
 @param accountName Account
 */
- (void)Cocos_GetDBAccount:(NSString *)accountName
                   Success:(SuccessBlock)successBlock
                     Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountName)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    // 2. Query database user information
    CocosDBAccountModel *dbWallet = [[CocosDataBase Cocos_shareDatabase] Cocos_QueryMyAccountWithName:accountName addChainId:[CocosConfig chainId]];
    if (dbWallet.name == nil) {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ not found",accountName] code:SDKErrorCodeAccountNotFound userInfo:@{@"account":accountName}];
        !errorBlock?:errorBlock(error);;
        return;
    }
    
    !successBlock?:successBlock(dbWallet);
}

/** Get account object by Account */
- (void)Cocos_GetAccount:(NSString *)accountIdOrName
                 Success:(SuccessBlock)successBlock
                   Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountIdOrName)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountIdOrName‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 2. Request user information
    ChainObjectId *object = [ChainObjectId generateFromObject:accountIdOrName];
    UploadParams *uploadParams = [[UploadParams alloc] init];
    if (object) {
        uploadParams.methodName = kCocosGetObjects;
        uploadParams.totalParams = @[@[object.generateToTransferObject]];
    }else {
        uploadParams.methodName = kCocosLookupAccountNames;
        
        uploadParams.totalParams = @[@[accountIdOrName]];
    }
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = ^(NSArray * result) {
        NSDictionary *dic = result.firstObject;
        if (!IsNilOrNull(dic)) {
            !successBlock?:successBlock(dic);
        }else{
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ not found",accountIdOrName] code:SDKErrorCodeAccountNotFound userInfo:@{@"account":accountIdOrName}];
            !errorBlock?:errorBlock(error);
        }
    };
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Get opreations about one account */
- (void)Cocos_GetAccountBalance:(NSString *)accountID
                         CoinID:(NSArray *)coinID
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountID)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountID‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetAccountBalances;
    
    uploadParams.totalParams = @[accountID,coinID];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
    
}

/** Get account history about one account */
- (void)Cocos_GetAccountHistory:(NSString *)accountID
                          Limit:(NSInteger)limit
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetAccountHistory;
    
    uploadParams.totalParams = @[accountID,@"1.11.0",@(limit),@"1.11.0"];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiHistory) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/**
 Get transaction about one hash
 
 @param transferhash   hash
 */
- (void)Cocos_GetTransactionById:(NSString *)transferhash
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetTransactionById;
    
    uploadParams.totalParams = @[transferhash];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];

}

/** Decrypt memo① */
- (void)Cocos_DecryptMemo:(NSDictionary *)memo
                  Private:(NSString *)active_key
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsNilOrNull(memo)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘memo’ can not be empty" code:SDKErrorCodeAccountMemoNotEmpty userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    if (IsStrEmpty(active_key)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘active_key‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    // 2. Transform data model
    NSString *_nonce = memo[@"nonce"];
    NSData *message = [[NSData alloc] initWithBase16EncodedString:memo[@"message"] options:0];
    NSString *fromString = [memo[@"from"] substringFromIndex:[CocosConfig prefix].length];
    NSString *toString = [memo[@"to"] substringFromIndex:[CocosConfig prefix].length];
    CocosPublicKey *memoFrom = [[CocosPublicKey alloc] initWithPubkeyString:fromString];
    CocosPublicKey *memoTo = [[CocosPublicKey alloc] initWithPubkeyString:toString];
    
    NSData *sha512SharedSecret = nil;
    
    // 3. Compare private keys and parse data
    CocosPrivateKey *privateKey = [[CocosPrivateKey alloc] initWithPrivateKey:active_key];
    if ([privateKey.publicKey isEqual:memoFrom]) {
        sha512SharedSecret = [privateKey getSharedSecret:memoTo];
    }else if ([privateKey.publicKey isEqual:memoTo]) {
        sha512SharedSecret = [privateKey getSharedSecret:memoFrom];
    }
    NSString *strNoncePlusSecret = [sha512SharedSecret base16EncodedStringWithOptions:(NSDataBase16EncodingOptionsLowerCase)];
    
    NSMutableData *customData = [[[NSString stringWithFormat:@"%@%@",_nonce,strNoncePlusSecret] dataUsingEncoding:NSASCIIStringEncoding] copy];
    
    // 4. Decrypt with AES using parameters such as private key
    sha512SharedSecret = [customData sha512Data];
    
    if (!sha512SharedSecret) {
        NSError *error = [NSError errorWithDomain:@"Parameter error" code:SDKErrorCodeErrorParameterError userInfo:@{@"memo":memo}];
        !errorBlock?:errorBlock(error);
        return;
    }
    NSData *keyData = [sha512SharedSecret copyWithRange:NSMakeRange(0, 32)];
    
    NSData *ivData = [sha512SharedSecret copyWithRange:NSMakeRange(32, 16)];
    
    NSData *decryptData = [message aes256Decrypt:keyData ivData:ivData];
    
    if (!decryptData){
        NSError *error = [NSError errorWithDomain:@"Parameter error" code:SDKErrorCodeErrorParameterError userInfo:@{@"memo":memo}];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    NSData *checkSumData = [decryptData copyWithRange:NSMakeRange(0, 4)];
    
    NSData *messageData = [decryptData copyWithRange:NSMakeRange(4, decryptData.length - 4)];
    
    NSData *sha256Data = [messageData sha256Data];
    
    if (![[sha256Data copyWithRange:NSMakeRange(0, 4)] isEqualToData:checkSumData]){
        NSError *error = [NSError errorWithDomain:@"Parameter error" code:SDKErrorCodeErrorParameterError userInfo:@{@"memo":memo}];
        !errorBlock?:errorBlock(error);
        return;
    }
    !successBlock?:successBlock([[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding]);
}
/** Decrypt memo② */
- (void)Cocos_DecryptMemo:(NSDictionary *)memo
              AccountName:(NSString *)accountName
                 Password:(NSString *)password
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock
{
    
    // 1. Validation parameters
    [self validateAccount:accountName Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Declassified private key
            [self Cocos_DecryptMemo:memo Private:keyDic[@"active_key"] Success:successBlock Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/**
 Upgrade Membership
 
 @param account account
 @param feePayingAsset feePayingAsset
 */
- (void)Cocos_UpgradeMemberFeeAccount:(NSString *)account
                       FeePayingAsset:(NSString *)feePayingAsset
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    // 1. account info
    [self Cocos_GetAccount:account Success:^(id responseObject) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:account];
        // 2. fee asset info
        [self Cocos_GetAsset:feePayingAsset Success:^(id feeAssetObject) {
            ChainAssetObject *feeAssetModel = [ChainAssetObject generateFromObject:feeAssetObject];
            CocosUpgradeMemberOperation *operation = [[CocosUpgradeMemberOperation alloc] init];
            operation.account_to_upgrade = accountModel.identifier;
            operation.upgrade_to_lifetime_member = YES;
            // 3. request fee
            [self Cocos_OperationFees:operation OperationType:7 FeePayingAsset:feeAssetModel.identifier.generateToTransferObject Success:successBlock Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/**
 Upgrade Membership
 
 @param account account
 @param feePayingAsset feePayingAsset
 */
- (void)Cocos_UpgradeMemberAccount:(NSString *)account
                          password:(NSString *)password
                    FeePayingAsset:(NSString *)feePayingAsset
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:account Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            // 3. account info
            [self Cocos_GetAccount:account Success:^(id responseObject) {
                ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
                // 4. Stitching transfer data
                CocosUpgradeMemberOperation *operation = [[CocosUpgradeMemberOperation alloc] init];
                operation.account_to_upgrade = accountModel.identifier;
                operation.upgrade_to_lifetime_member = YES;
                // 5. Inquiry fee
                [self Cocos_UpgradeMemberFeeAccount:account FeePayingAsset:feePayingAsset Success:^(NSArray *feeObject) {
                    // 6. Stitching fee
                    NSDictionary *feeDic = feeObject.firstObject;
                    operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
                    CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                    SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                    signedTran.operations = @[content];
                    // 7. Transfer
                    [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

#pragma mark - Asset query operation
/** Get blockchain assets list */
- (void)Cocos_ChainListLimit:(NSInteger)nLimit
                     Success:(SuccessBlock)successBlock
                       Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosListAssets;
    
    uploadParams.totalParams = @[@"",@(nLimit)];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Get Asset by name */
- (void)Cocos_GetAsset:(NSString *)assetIdOrName
               Success:(SuccessBlock)successBlock
                 Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(assetIdOrName)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘assetIdOrName‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    ChainObjectId *object = [ChainObjectId generateFromObject:assetIdOrName];
    
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    if (object) {
        uploadParams.methodName = kCocosGetObjects;
        
        uploadParams.totalParams = @[@[object.generateToTransferObject]];
    }else {
        uploadParams.methodName = kCocosLookupAssetSymbols;
        
        uploadParams.totalParams = @[@[assetIdOrName]];
    }
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = ^(NSArray * result) {
        NSDictionary *dic = result.firstObject;
        !successBlock?:successBlock(dic);
    };
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Get Asset object by ID [eg.1.3.n] */
- (void)Cocos_GetAssets:(NSArray *)assetIds
                Success:(SuccessBlock)successBlock
                  Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetObjects;
    
    uploadParams.totalParams = @[assetIds];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Get object by IDs [eg.1.3.n] */
- (void)Cocos_GetObjects:(NSArray *)objectIds
                 Success:(SuccessBlock)successBlock
                   Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetObjects;
    
    uploadParams.totalParams = @[objectIds];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Transfer fee */
- (void)Cocos_GetTransferFeesFrom:(NSString *)fromName
                        ToAccount:(NSString *)toName
                         Password:(NSString *)password
                    TransferAsset:(NSString *)transferAsset
                      AssetAmount:(NSString *)assetAmount
                   FeePayingAsset:(NSString *)feePayingAsset
                             Memo:(NSString *)memo
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:fromName Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key To Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            // 3. Get the transfer object
            [self getTransferObjFromAccount:fromName toAccount:toName activePrivate:private transferAsset:transferAsset feePayingAsset:feePayingAsset memo:memo Success:^(NSDictionary *operationObj) {
                
                ChainAccountModel *fromModel = operationObj[@"fromModel"];
                ChainAccountModel *toModel = operationObj[@"toModel"];
                ChainAssetObject *assetModel = operationObj[@"assetModel"];
                ChainAssetObject *feeAssetModel = operationObj[@"feeAssetModel"];
                ChainMemo *memoData = operationObj[@"memoData"];
                
                // 2. Stitching transfer data
                CocosTransferOperation *operation = [[CocosTransferOperation alloc] init];
                operation.from = fromModel.identifier;
                operation.to = toModel.identifier;
                operation.amount = [assetModel getAmountFromNormalFloatString:[NSString stringWithFormat:@"%@",assetAmount]];
                operation.requiredAuthority = fromModel.active.publicKeys;
                if (memoData) {
                    operation.memo = memoData;
                }
                // 3. Inquiry fee
                [self Cocos_OperationFees:operation OperationType:0 FeePayingAsset:feeAssetModel.identifier.generateToTransferObject Success:successBlock Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/** Transfer */
- (void)Cocos_TransferFromAccount:(NSString *)fromName
                        ToAccount:(NSString *)toName
                         Password:(NSString *)password
                    TransferAsset:(NSString *)transferAsset
                      AssetAmount:(NSString *)assetAmount
                   FeePayingAsset:(NSString *)feePayingAsset
                             Memo:(NSString *)memo
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:fromName Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            [self transferFromAccount:fromName toAccount:toName activePrivate:private transferAsset:transferAsset assetAmount:assetAmount feePayingAsset:feePayingAsset memo:memo Success:successBlock Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/**
 Receivables (String used to generate two-dimensional receipt code)
 */
- (void)Cocos_Receivables:(NSString *)receiver
                   Symbol:(NSString *)symbol
                   Amount:(NSString *)amount
               Fee_symbol:(NSString *)fee_symbol
                     Memo:(NSString *)memo
                   Custom:(NSString *)custom
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(receiver) || IsStrEmpty(symbol) || IsStrEmpty(fee_symbol)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘receiver‘ 、‘symbol‘ Or ‘fee_symbol‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    NSMutableDictionary *receiveJson = [NSMutableDictionary dictionary];
    receiveJson[@"receiver"] = receiver;
    receiveJson[@"symbol"] = symbol;
    receiveJson[@"fee_symbol"] = fee_symbol;
    receiveJson[@"amount"] = amount?:@"";
    receiveJson[@"memo"] = memo?:@"";
    receiveJson[@"custom"] = custom?:@"";
    !successBlock?:successBlock(receiveJson);
}

/** Get global variable parameter(latest blocks news etc.) */
- (void)Cocos_GetDynamicGlobalPropertiesWithSuccess:(SuccessBlock)successBlock Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetDynamicGlobalProperties;
    
    uploadParams.totalParams = @[];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Get Block Header */
- (void)Cocos_GetBlockHeaderWithBlockNum:(NSNumber *)blockNum
                                 Success:(SuccessBlock)successBlock
                                   Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetBlockHeader;
    
    uploadParams.totalParams = @[blockNum];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
    
}

/** Get Transaction In Block Info  */
- (void)Cocos_GetTransactionBlockWithHash:(NSString *)tansferHash
                                  Success:(SuccessBlock)successBlock
                                    Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetTransactionBlock;
    
    uploadParams.totalParams = @[tansferHash];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Get Block */
- (void)Cocos_GetBlockWithBlockNum:(NSNumber *)blockNum
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetBlock;
    
    uploadParams.totalParams = @[blockNum];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
    
}

// Get Contract Info
- (void)Cocos_GetContract:(NSString *)contractIdOrName
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetContract;
    
    uploadParams.totalParams = @[contractIdOrName];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

// Get Contract Info
- (void)Cocos_GetContractCreatInfo:(NSString *)current_version
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetTransactionById;
    
    uploadParams.totalParams = @[current_version];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

// Get Contract Info of Account
- (void)Cocos_GetAccountContractData:(NSString *)accountId
                          ContractId:(NSString *)contractId
                             Success:(SuccessBlock)successBlock
                               Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    
    uploadParams.methodName = kCocosGetAccountContractData;
    
    uploadParams.totalParams = @[accountId,contractId];
    
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    
    callBackModel.successResult = successBlock;
    
    callBackModel.errorResult = errorBlock;
    
    [self sendWithChainApi:(WebsocketBlockChainApiDataBase) method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Call contract Fee */
- (void)Cocos_GetCallContractFee:(NSString *)contractIdOrName
             ContractMethodParam:(NSArray *)param
                  ContractMethod:(NSString *)contractmMethod
                   CallerAccount:(NSString *)accountIdOrName
                  feePayingAsset:(NSString *)feePayingAsset
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock
{
    // 1. Inquiry for transferor information
    [self Cocos_GetAccount:accountIdOrName Success:^(id account) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:account];
        // 2. Get Contract Info
        [self Cocos_GetContract:contractIdOrName Success:^(id contract) {
            ChainContract *contractModel = [ChainContract generateFromObject:contract];
            // 3. Stitching transfer data
            CocosCallContractOperation *operation = [[CocosCallContractOperation alloc] init];
            operation.caller = accountModel.identifier;
            operation.contract_id = contractModel.identifier;
            operation.requiredAuthority = accountModel.active.publicKeys;
            operation.function_name = contractmMethod;
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSString *paramStr in param) {
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:@(2)];
                NSDictionary *dic = @{@"v":paramStr};
                [array addObject:dic];
                [tempArray addObject:array];
            }
            operation.value_list = tempArray;
            
            [self Cocos_OperationFees:operation OperationType:44 FeePayingAsset:feePayingAsset Success:successBlock Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/** Call contract */
- (void)Cocos_CallContract:(NSString *)contractIdOrName
       ContractMethodParam:(NSArray *)param
            ContractMethod:(NSString *)contractmMethod
             CallerAccount:(NSString *)accountIdOrName
            feePayingAsset:(NSString *)feePayingAsset
                  Password:(NSString *)password
                   Success:(SuccessBlock)successBlock
                     Error:(Error)errorBlock
{
    
    // 1. Inquiry for transferor information
    [self Cocos_GetAccount:accountIdOrName Success:^(id account) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:account];
        
        // 2. get Contract Info
        [self Cocos_GetContract:contractIdOrName Success:^(id contract) {
            ChainContract *contractModel = [ChainContract generateFromObject:contract];
            // 3. Account password decryption
            [self validateAccount:accountModel.name Password:password Success:^(NSDictionary *keyDic) {
                if (keyDic[@"active_key"]) {
                    // 4. Generating Private Key Transfer
                    CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
                    // 5. Stitching transfer data
                    CocosCallContractOperation *operation = [[CocosCallContractOperation alloc] init];
                    operation.caller = accountModel.identifier;
                    operation.contract_id = contractModel.identifier;
                    operation.requiredAuthority = accountModel.active.publicKeys;
                    operation.function_name = contractmMethod;
                    NSMutableArray *tempArray = [NSMutableArray array];
                    
                    if (param.count == 0) {
                        NSMutableArray *array = [NSMutableArray array];
                        [array addObject:@(2)];
                        [array addObject:@{@"v":@""}];
                        [tempArray addObject:array];
                    }else{
                        for (NSString *paramStr in param) {
                            NSMutableArray *array = [NSMutableArray array];
                            [array addObject:@(2)];
                            NSDictionary *dic = @{@"v":paramStr};
                            [array addObject:dic];
                            [tempArray addObject:array];
                        }
                    }
                    operation.value_list = tempArray;
                    
                    // 6. Inquiry fee
                    [self Cocos_OperationFees:operation OperationType:44 FeePayingAsset:feePayingAsset Success:^(NSArray *feeObject) {
                        // 7. Stitching fee
                        NSDictionary *feeDic = feeObject.firstObject;
                        operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
                        CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                        SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                        signedTran.operations = @[content];
                        // 8. Call contract
                        [self signedTransaction:signedTran activePrivate:private Success:^(id transactionhash) {
                            // 9. Get Transfer Block with hash
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                dispatch_semaphore_t disp = dispatch_semaphore_create(0);
                                do {
                                    [self Cocos_GetTransactionBlockWithHash:transactionhash Success:^(id blockResponse) {
                                        if (blockResponse == nil || blockResponse[@"block_num"] == nil) {
                                            dispatch_semaphore_signal(disp);
                                        }else{
                                            // 10. Get Block with Block Num
                                            [self Cocos_GetBlockWithBlockNum:blockResponse[@"block_num"] Success:^(id responseObject) {
                                                [self CallContractSuccessResponseWithTrxHash:transactionhash blockNum:blockResponse[@"block_num"] resultData:responseObject succeed:^(NSMutableDictionary *callContractRes) {
                                                    // 主线程回调
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        !successBlock?:successBlock(callContractRes);
                                                    });
                                                }];
                                            } Error:errorBlock];
                                        }
                                    } Error:errorBlock];
                                    // 2. 等待信号
                                    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
                                } while (1);
                            });
                        } Error:errorBlock];
                    } Error:errorBlock];
                }else if (keyDic[@"owner_key"]){
                    NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
                    !errorBlock?:errorBlock(error);
                }else{
                    NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
                    !errorBlock?:errorBlock(error);
                }
            } Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/** 成功调用合约返回值 */
- (void)CallContractSuccessResponseWithTrxHash:(NSString *)trxhash
                                      blockNum:(NSNumber *)blockNum
                                    resultData:(NSDictionary *)resultData
                                       succeed:(void (^)(NSMutableDictionary *callContractRes))block
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 遍历找到此交易的数组
        NSArray *transactionsArray = resultData[@"transactions"];
        
        // 查到有用的数组
        NSArray *resultArray = [NSArray array];
        for (NSArray *transferArray in transactionsArray) {
            if ([[transferArray firstObject] isEqualToString:trxhash]) {
                resultArray = transferArray;
                break;
            }
        }
        NSDictionary *resultDic = [resultArray lastObject];
        NSArray *operationArray = resultDic[@"operation_results"];
        NSDictionary *operationDic = [[operationArray lastObject] lastObject];
        // 拼接dataDic
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        dataDic[@"contract_id"] = operationDic[@"contract_id"];
        dataDic[@"real_running_time"] = operationDic[@"real_running_time"];
        dataDic[@"existed_pv"] = operationDic[@"existed_pv"];
        dataDic[@"process_value"] = operationDic[@"process_value"];
        dataDic[@"additional_cost"]= operationDic[@"additional_cost"];
        
        NSArray *affectedsArray = operationDic[@"contract_affecteds"];
        NSMutableArray *resAffecteds = [NSMutableArray array];
        
        for (NSArray *subAffecteds in affectedsArray) {
            
            dispatch_semaphore_t disp = dispatch_semaphore_create(0);
            //1 .网络获取  返回数据加入缓存 存入数据库(假如 是转接的会话，必须需要全量获取，防止出现断层)
            NSMutableDictionary *affectedDic = [NSMutableDictionary dictionary];
            affectedDic[@"block_num"] = blockNum;
            NSDictionary *affected_dic = [subAffecteds lastObject];
            affectedDic[@"raw_data"] = affected_dic;
            NSString *account = affected_dic[@"affected_account"];
            
            if ([subAffecteds.firstObject intValue] == 0) {
                affectedDic[@"type"] = @"contract_affecteds_asset";
                affectedDic[@"type_name"] = @"资产";
                NSDictionary *assetDic = affected_dic[@"affected_asset"];
                [self Cocos_GetAccount:account Success:^(id accountRes) {
                    NSString *accountName = accountRes[@"name"];
                    [self Cocos_GetAsset:assetDic[@"asset_id"] Success:^(id affectedRes) {
                        NSNumber *amount = assetDic[@"amount"];
                        
                        long tempAmount = 0;
                        if ([amount intValue]<0) {
                            tempAmount = - [amount longValue];
                        }else{
                            tempAmount = [amount longValue];
                        }
                        ChainAssetObject *affectedModel = [ChainAssetObject generateFromObject:affectedRes];
                        
                        ChainAssetAmountObject *chainAssetAmount = [[ChainAssetAmountObject alloc] initFromAssetId:affectedModel.identifier amount:tempAmount];
                        NSString *assetsAmount = [affectedModel getRealAmountFromAssetAmount:chainAssetAmount];
                        
                        NSString *ass_amount = [NSString stringWithFormat:@"%@%@ %@",([amount intValue]<0)?@"-":@"+",assetsAmount,affectedModel.symbol];
                        affectedDic[@"result"] = @{
                                                   @"affected_account":accountName,
                                                   @"aseet_amount":ass_amount
                                                   };
                        affectedDic[@"result_text"] = [NSString stringWithFormat:@"%@ %@",accountName,ass_amount];
                        // 1 .发送信号 去数据库获取
                        dispatch_semaphore_signal(disp);
                        
                    } Error:^(NSError *error) {
                        dispatch_semaphore_signal(disp);
                    }];
                } Error:^(NSError *error) {
                    dispatch_semaphore_signal(disp);
                }];
            }else if ([subAffecteds.firstObject intValue] == 1) {
                
                [self Cocos_GetAccount:account Success:^(id accountRes) {
                    NSString *accountName = accountRes[@"name"];
                    NSString *affected_item = affected_dic[@"affected_item"];
                    affectedDic[@"result"] = @{
                                               @"affected_account":accountName,
                                               @"affected_item":affected_item
                                               };
                    if ([affected_dic[@"action"] integerValue] == 0) {
                        affectedDic[@"type"] = @"contract_affecteds_nh_transfer_from";
                        affectedDic[@"type_name"] = @"NH资产转出";
                        
                        affectedDic[@"result_text"] = [NSString stringWithFormat:@"%@ 的NH资产 %@ 转出",accountName,affected_item];
                    }else if ([affected_dic[@"action"] integerValue] == 1) {
                        affectedDic[@"type"] = @"contract_affecteds_nh_transfer_to";
                        affectedDic[@"type_name"] = @"NH资产转入";
                        affectedDic[@"result_text"] = [NSString stringWithFormat:@"NH资产 %@ 转入 %@ ",affected_item,accountName];
                    }else if ([affected_dic[@"action"] integerValue] == 2) {
                        affectedDic[@"type"] = @"contract_affecteds_nh_modifined";
                        affectedDic[@"type_name"] = @"NH资产数据修改";
                        
                        NSArray *modified = affected_dic[@"modified"];
                        NSDictionary *modifiDic = @{modified.firstObject:modified.lastObject};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modifiDic options:0 error:0];
                        NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        affectedDic[@"result"] = @{
                                                   @"affected_account":accountName,
                                                   @"affected_item":affected_item,
                                                   @"modified":dataStr
                                                   };
                        affectedDic[@"result_text"] = [NSString stringWithFormat:@"%@ 的NH资产 4.2.1151 修改数据 %@",accountName,dataStr];
                    }
                    dispatch_semaphore_signal(disp);
                } Error:^(NSError *error) {
                    dispatch_semaphore_signal(disp);
                }];
                
            }else if ([subAffecteds.firstObject intValue] == 2) {
                dispatch_semaphore_signal(disp);
            }else if ([subAffecteds.firstObject intValue] == 3) {
                affectedDic[@"type"] = @"contract_affecteds_log";
                affectedDic[@"type_name"] = @"日志";
                [self Cocos_GetAccount:account Success:^(id accountRes) {
                    NSString *accountName = accountRes[@"name"];
                    NSString *message = affected_dic[@"message"];
                    affectedDic[@"result"] = @{
                                               @"affected_account":accountName,
                                               @"message":message
                                               };
                    affectedDic[@"result_text"] = [NSString stringWithFormat:@"%@ %@",accountName,message];
                    // 1 .发送信号 去数据库获取
                    dispatch_semaphore_signal(disp);
                } Error:^(NSError *error) {
                    dispatch_semaphore_signal(disp);
                }];
            }else{
                dispatch_semaphore_signal(disp);
            }
            
            // 2. 等待信号
            dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
            [resAffecteds addObject:affectedDic];
        }
        dataDic[@"contract_affecteds"] = resAffecteds;
        
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"code"] = @1;
        response[@"trx_data"] = @{
                                  @"trx_id":trxhash,
                                  @"block_num":blockNum
                                  };
        response[@"data"] = @[dataDic];
        
        // 主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            !block?:block(response);
        });
    });
}
// Get NH Asset's details
- (void)Cocos_LookupNHAsset:(NSArray *)assetidOrhashArray
                    Success:(SuccessBlock)successBlock
                      Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosLookUpNHAssets;
    uploadParams.totalParams = @[assetidOrhashArray];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

// Get account's all NH assets
- (void)Cocos_ListAccountNHAsset:(NSString *)accountID
                       WorldView:(NSArray *)worldViewIDArray
                        PageSize:(NSInteger)pageSize
                            Page:(NSInteger)page
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosListAccountNHAssets;
    uploadParams.totalParams = @[accountID,worldViewIDArray,@(pageSize),@(page),@(4)];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

// Get account's NH assets‘ sell list
- (void)Cocos_ListAccountNHAssetOrder:(NSString *)accountID
                             PageSize:(NSInteger)pageSize
                                 Page:(NSInteger)page
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosListAccountNHOrder;
    uploadParams.totalParams = @[accountID,@(pageSize),@(page)];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

// Get sell list of NH assets on web
- (void)Cocos_AllListNHAssetOrder:(NSString *)assetID
                        WorldView:(NSString *)worldViewIDOrName
                     BaseDescribe:(NSString *)baseDescribe
                         PageSize:(NSInteger)pageSize
                             Page:(NSInteger)page
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosListNHOrder;
    uploadParams.totalParams = @[assetID,worldViewIDOrName,baseDescribe,@(pageSize),@(page),@(YES)];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

// Get world view's details
- (void)Cocos_LookupWorldView:(NSArray *)worldViewIDOrNameArray
                      Success:(SuccessBlock)successBlock
                        Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosLookUpWorldView;
    uploadParams.totalParams = @[worldViewIDOrNameArray];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

// Get NH assets that creator created
- (void)Cocos_ListNHAssetByCreator:(NSString *)accountID
                          PageSize:(NSInteger)pageSize
                              Page:(NSInteger)page
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock;
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosListNHbyCreator;
    uploadParams.totalParams = @[accountID,@(pageSize),@(page)];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** assets transfer fee */
- (void)Cocos_TransferNHAssetFee:(NSString *)from
                       ToAccount:(NSString *)to
                       NHAssetID:(NSString *)NHAssetID
                  FeePayingAsset:(NSString *)feePayingAssetID
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock
{
    [self getOperationFromAccount:from toAccount:to feePayingAsset:feePayingAssetID Success:^(NSDictionary *operationObj) {
        ChainAccountModel *fromModel = operationObj[@"fromModel"];
        ChainAccountModel *toModel = operationObj[@"toModel"];
        // 2. Stitching transfer data
        CocosTransferNHOperation *operation = [[CocosTransferNHOperation alloc] init];
        operation.from = fromModel.identifier;
        operation.to = toModel.identifier;
        operation.nh_asset = [ChainObjectId createFromString:NHAssetID];
        operation.requiredAuthority = fromModel.active.publicKeys;
        // 3. Inquiry fee
        [self Cocos_OperationFees:operation OperationType:51 FeePayingAsset:feePayingAssetID Success:successBlock Error:errorBlock];
    } Error:errorBlock];
}

/** assets transfer */
- (void)Cocos_TransferNHAsset:(NSString *)from
                    ToAccount:(NSString *)to
                    NHAssetID:(NSString *)NHAssetID
                     Password:(NSString *)password
               FeePayingAsset:(NSString *)feePayingAssetID
                      Success:(SuccessBlock)successBlock
                        Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:from Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            [self getOperationFromAccount:from toAccount:to feePayingAsset:feePayingAssetID Success:^(NSDictionary *operationObj) {
                ChainAccountModel *fromModel = operationObj[@"fromModel"];
                ChainAccountModel *toModel = operationObj[@"toModel"];
                // 2. Stitching transfer data
                CocosTransferNHOperation *operation = [[CocosTransferNHOperation alloc] init];
                operation.from = fromModel.identifier;
                operation.to = toModel.identifier;
                operation.nh_asset = [ChainObjectId createFromString:NHAssetID];
                operation.requiredAuthority = fromModel.active.publicKeys;
                // 3. Inquiry fee
                [self Cocos_OperationFees:operation OperationType:51 FeePayingAsset:feePayingAssetID Success:^(NSArray * feeObject) {
                    // 4. Stitching fee
                    NSDictionary *feeDic = feeObject.firstObject;
                    operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
                    CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                    SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                    signedTran.operations = @[content];
                    // 5. Transfer
                    [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/**
 Get fee of buying NH Asset
 */
- (void)Cocos_BuyNHAssetFeeOrderID:(NSString *)orderID
                           Account:(NSString *)account
                    FeePayingAsset:(NSString *)feePayingAssetID
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    // 1. request Order
    [self Cocos_GetObjects:@[orderID] Success:^(id responseObject) {
        ChainNHAssetOrder *NHAssetOrder = [ChainNHAssetOrder generateFromObject:[responseObject lastObject]];
        // 2. request account
        [self Cocos_GetAccount:account Success:^(id accountObj) {
            ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:accountObj];
            // 3. Search for asset information
            [self Cocos_GetAsset:feePayingAssetID Success:^(id feeAssetObject) {
                ChainAssetObject *feeAssetModel = [ChainAssetObject generateFromObject:feeAssetObject];
                // 4. request Order Price
                [self Cocos_GetAsset:[NHAssetOrder.price.assetId generateToTransferObject] Success:^(id priceObj) {
                    ChainAssetObject *priceModel = [ChainAssetObject generateFromObject:priceObj];
                    NSString *price_amount = [priceModel getRealAmountFromAssetAmount:NHAssetOrder.price];
                    
                    // 5. Return the operation object
                    CocosBuyNHOrderOperation *operation = [[CocosBuyNHOrderOperation alloc] init];
                    operation.fee_paying_account = accountModel.identifier;
                    operation.order = NHAssetOrder.identifier;
                    operation.seller = NHAssetOrder.seller;
                    operation.nh_asset = NHAssetOrder.nh_asset_id;
                    operation.price_amount = price_amount;
                    operation.price_asset_id = priceModel.identifier;
                    operation.price_asset_symbol = priceModel.symbol;
                    // 6. Inquiry fee
                    [self Cocos_OperationFees:operation OperationType:54 FeePayingAsset:[feeAssetModel.identifier generateToTransferObject] Success:successBlock Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/**
 Buy NH assets
 */
- (void)Cocos_BuyNHAssetOrderID:(NSString *)orderID
                        Account:(NSString *)account
                       Password:(NSString *)password
                 FeePayingAsset:(NSString *)feePayingAssetID
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock
{
    
    // 1. Account password decryption
    [self validateAccount:account Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            // 1. request Order
            [self Cocos_GetObjects:@[orderID] Success:^(id responseObject) {
                ChainNHAssetOrder *NHAssetOrder = [ChainNHAssetOrder generateFromObject:[responseObject lastObject]];
                // 2. request account
                [self Cocos_GetAccount:account Success:^(id accountObj) {
                    ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:accountObj];
                    // 3. Search for asset information
                    [self Cocos_GetAsset:feePayingAssetID Success:^(id feeAssetObject) {
                        ChainAssetObject *feeAssetModel = [ChainAssetObject generateFromObject:feeAssetObject];
                        // 4. request Order Price
                        [self Cocos_GetAsset:[NHAssetOrder.price.assetId generateToTransferObject] Success:^(id priceObj) {
                            ChainAssetObject *priceModel = [ChainAssetObject generateFromObject:priceObj];
                            NSString *price_amount = [priceModel getRealAmountFromAssetAmount:NHAssetOrder.price];
                            
                            // 5. Return the operation object
                            CocosBuyNHOrderOperation *operation = [[CocosBuyNHOrderOperation alloc] init];
                            operation.fee_paying_account = accountModel.identifier;
                            operation.order = NHAssetOrder.identifier;
                            operation.seller = NHAssetOrder.seller;
                            operation.nh_asset = NHAssetOrder.nh_asset_id;
                            operation.price_amount = price_amount;
                            operation.price_asset_id = priceModel.identifier;
                            operation.price_asset_symbol = priceModel.symbol;
                            // 6. Inquiry fee
                            [self Cocos_OperationFees:operation OperationType:54 FeePayingAsset:[feeAssetModel.identifier generateToTransferObject] Success:^(NSArray *feeObject) {
                                // 7. Stitching fee
                                NSDictionary *feeDic = feeObject.firstObject;
                                operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
                                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                                signedTran.operations = @[content];
                                // 8. Call contract
                                [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                            } Error:errorBlock];
                        } Error:errorBlock];
                    } Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/** Delete NH assets Fee */
- (void)Cocos_DeleteNHAssetFeeAccount:(NSString *)account
                       FeePayingAsset:(NSString *)feePayingAsset
                            nhAssetID:(NSString *)nhAssetID
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    // 1. account info
    [self Cocos_GetAccount:account Success:^(id responseObject) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
        // 2. fee asset info
        [self Cocos_GetAsset:feePayingAsset Success:^(id feeAssetObject) {
            ChainAssetObject *feeAssetModel = [ChainAssetObject generateFromObject:feeAssetObject];
            CocosDeleteNHOperation *operation = [[CocosDeleteNHOperation alloc] init];
            operation.fee_paying_account = accountModel.identifier;
            operation.nh_asset = [ChainObjectId generateFromObject:nhAssetID];
            // 3. request fee
            [self Cocos_OperationFees:operation OperationType:50 FeePayingAsset:feeAssetModel.identifier.generateToTransferObject Success:successBlock Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/** Delete NH assets */
- (void)Cocos_DeleteNHAssetAccount:(NSString *)account
                          Password:(NSString *)password
                    FeePayingAsset:(NSString *)feePayingAsset
                         nhAssetID:(NSString *)nhAssetID
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    // 1. valida password
    [self validateAccount:account Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            // 3. account info
            [self Cocos_GetAccount:account Success:^(id responseObject) {
                ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
                // 4. Stitching transfer data
                CocosDeleteNHOperation *operation = [[CocosDeleteNHOperation alloc] init];
                operation.fee_paying_account = accountModel.identifier;
                operation.nh_asset = [ChainObjectId generateFromObject:nhAssetID] ;
                // 5. Inquiry fee
                [self Cocos_DeleteNHAssetFeeAccount:account FeePayingAsset:feePayingAsset nhAssetID:nhAssetID Success:^(NSArray *feeObject) {
                    // 6. Stitching fee
                    NSDictionary *feeDic = feeObject.firstObject;
                    operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
                    CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                    SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                    signedTran.operations = @[content];
                    // 7. Delete
                    [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/** cancel sell NH assets Fee */
- (void)Cocos_CancelNHAssetFeeAccount:(NSString *)account
                       FeePayingAsset:(NSString *)feePayingAsset
                              OrderId:(NSString *)orderId
                              Success:(SuccessBlock)successBlock
                                Error:(Error)errorBlock
{
    // 1. account info
    [self Cocos_GetAccount:account Success:^(id responseObject) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
        // 2. fee asset info
        [self Cocos_GetAsset:feePayingAsset Success:^(id feeAssetObject) {
            ChainAssetObject *feeAssetModel = [ChainAssetObject generateFromObject:feeAssetObject];
            CocosSellNHAssetCancelOperation *operation = [[CocosSellNHAssetCancelOperation alloc] init];
            operation.fee_paying_account = accountModel.identifier;
            operation.order = [ChainObjectId generateFromObject:orderId];
            // 3. request fee
            [self Cocos_OperationFees:operation OperationType:53 FeePayingAsset:feeAssetModel.identifier.generateToTransferObject Success:successBlock Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}
/** cancel sell NH assets */
- (void)Cocos_CancelNHAssetAccount:(NSString *)account
                          Password:(NSString *)password
                    FeePayingAsset:(NSString *)feePayingAsset
                           OrderId:(NSString *)orderId
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    // 1. valida password
    [self validateAccount:account Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            // 3. account info
            [self Cocos_GetAccount:account Success:^(id responseObject) {
                ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
                // 4. Stitching transfer data
                CocosSellNHAssetCancelOperation *operation = [[CocosSellNHAssetCancelOperation alloc] init];
                operation.fee_paying_account = accountModel.identifier;
                operation.order = [ChainObjectId generateFromObject:orderId] ;
                // 5. Inquiry fee
                [self Cocos_CancelNHAssetFeeAccount:account FeePayingAsset:feePayingAsset OrderId:orderId Success:^(NSArray *feeObject) {
                    // 6. Stitching fee
                    NSDictionary *feeDic = feeObject.firstObject;
                    operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
                    CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                    SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                    signedTran.operations = @[content];
                    // 7. Delete
                    [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/** Sell NH assets Fee */
- (void)Cocos_SellNHAssetFeeSeller:(NSString *)SellerAccount
                         NHAssetId:(NSString *)nhAssetid
                              Memo:(NSString *)memo
                   SellPriceAmount:(NSString *)priceAmount
                  PendingFeeAmount:(NSString *)pendingFeeAmount
                    OperationAsset:(NSString *)opAsset
                         SellAsset:(NSString *)sellAsset
                        Expiration:(NSString *)expiration
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    // 1. account info
    [self sellNHAssetOperationSeller:SellerAccount NHAssetId:nhAssetid Memo:memo SellPriceAmount:priceAmount PendingFeeAmount:pendingFeeAmount OperationAsset:opAsset SellAsset:sellAsset Expiration:expiration Success:^(NSDictionary *callback) {
        CocosSellNHAssetOperation *operation = callback[@"operation"];
        ChainAssetObject *opAsset = callback[@"opAsset"];
        // 2. fee asset info
        [self Cocos_OperationFees:operation OperationType:52 FeePayingAsset:opAsset.identifier.generateToTransferObject Success:successBlock Error:errorBlock];
    } Error:errorBlock];
}

/** Sell NH assets */

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
                          Error:(Error)errorBlock
{
    // 1. validateAccount
    [self validateAccount:SellerAccount Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Declassified private key
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            [self sellNHAssetOperationSeller:SellerAccount NHAssetId:nhAssetid Memo:memo SellPriceAmount:priceAmount PendingFeeAmount:pendingFeeAmount OperationAsset:opAsset SellAsset:sellAsset Expiration:expiration Success:^(NSDictionary *callback) {
                CocosSellNHAssetOperation *operation = callback[@"operation"];
                ChainAssetObject *opAsset = callback[@"opAsset"];
                // 3. fee asset info
                [self Cocos_OperationFees:operation OperationType:52 FeePayingAsset:opAsset.identifier.generateToTransferObject Success:^(NSArray *feeObject) {
                    // 4. Stitching fee
                    NSDictionary *feeDic = feeObject.firstObject;
                    operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
                    CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                    SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                    signedTran.operations = @[content];
                    // 5. Delete
                    [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"owner_key"]){
            NSError *error = [NSError errorWithDomain:@"Please import the active private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/** Sell NH assets MaxExpiration */
- (void)Cocos_SellNHAssetMaxExpirationSuccess:(SuccessBlock)successBlock Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosSellNHAssetExpiration;
    uploadParams.totalParams = @[@[]];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

#pragma mark - Expanding Method
- (void)sellNHAssetOperationSeller:(NSString *)SellerAccount
                         NHAssetId:(NSString *)nhAssetid
                              Memo:(NSString *)memo
                   SellPriceAmount:(NSString *)priceAmount
                  PendingFeeAmount:(NSString *)pendingFeeAmount
                    OperationAsset:(NSString *)opAsset
                         SellAsset:(NSString *)sellAsset
                        Expiration:(NSString *)expiration
                           Success:(SuccessBlock)successBlock
                             Error:(Error)errorBlock
{
    // 1. account info
    [self Cocos_GetAccount:SellerAccount Success:^(id responseObject) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
        // 2. fee asset info
        [self Cocos_GetAsset:opAsset Success:^(id assetObject) {
            ChainAssetObject *opAssetModel = [ChainAssetObject generateFromObject:assetObject];
            ChainAssetAmountObject *pendingAmout = [opAssetModel getAmountFromNormalFloatString:pendingFeeAmount];
            CocosSellNHAssetOperation *operation = [[CocosSellNHAssetOperation alloc] init];
            operation.seller = accountModel.identifier;
            operation.otcaccount = [ChainObjectId generateFromObject:@"1.2.11233"];
            operation.pending_orders_fee = pendingAmout;
            operation.nh_asset = [ChainObjectId generateFromObject:nhAssetid];
            operation.memo = memo;
            operation.expiration = [[NSDate date] dateByAddingTimeInterval:[expiration doubleValue]];
            // 3. price Amount
            [self Cocos_GetAsset:sellAsset Success:^(id sellAssetResObj) {
                ChainAssetObject *sellAssetModel = [ChainAssetObject generateFromObject:sellAssetResObj];
                ChainAssetAmountObject *priceAmout = [sellAssetModel getAmountFromNormalFloatString:priceAmount];
                operation.price = priceAmout;
                // 3. Callback CocosBaseOperation
                NSDictionary *callback = @{
                                           @"operation":operation,
                                           @"opAsset":opAssetModel,
                                           };
                !successBlock?:successBlock(callback);
            } Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}
/** operation fee */
- (void)Cocos_OperationFees:(CocosBaseOperation *)operation
              OperationType:(NSInteger)operationType
             FeePayingAsset:(NSString *)feePayingAssetID
                    Success:(SuccessBlock)successBlock
                      Error:(Error)errorBlock
{
    // Transfer type is ‘0’
    NSArray *paramArray = @[@(operationType),[operation generateToTransferObject]];
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosGetRequiredFees;
    uploadParams.totalParams = @[@[paramArray],feePayingAssetID];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** Expand custom api */
- (void)Cocos_SendWithChainApi:(WebsocketBlockChainApi)chainApi
                        Method:(WebsocketBlockChainMethodApi)method
                    MethodName:(NSString *)methodName
                        Params:(NSArray *)uploadParamsArray
                       Success:(SuccessBlock)successBlock
                         Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = methodName;
    uploadParams.totalParams = uploadParamsArray;
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [_client sendWithChainApi:chainApi method:method params:uploadParams callBack:callBackModel];
}

#pragma mark - Private
/** Decrypt keystone */
- (void)DecryptKeyStone:(NSString *)keystone
            KeystonePwd:(NSString *)keystonePwd
        SaveAccountInfo:(BOOL)isSaveInfo
                Success:(SuccessBlock)successBlock
                  Error:(Error)errorBlock
{
    // 1. Analysis keystone
    NSDictionary *keystoneDic = [NSJSONSerialization JSONObjectWithData:[keystone dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingAllowFragments) error:nil];
    if (!keystoneDic) {
        NSError *error = [NSError errorWithDomain:@"Please check parameter data type" code:SDKErrorCodeParameterDataTypeError userInfo:@{@"keystone":keystone}];
        !errorBlock?:errorBlock(error);;
        return;
    }
    // 2. Transform model
    KeystoneFile *keystoneFile = [KeystoneFile generateFromObject:keystoneDic];
    if (!keystoneFile) {
        NSError *error = [NSError errorWithDomain:@"Please check parameter data type" code:SDKErrorCodeParameterDataTypeError userInfo:@{@"keystone":keystone}];
        !errorBlock?:errorBlock(error);;
        return;
    }
    
    // 3. Query account information
    [self Cocos_GetAccount:[[keystoneFile.extra_keys firstObject].keyId description] Success:^(id account) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:account];
        CocosPrivateKey *ownerPri = [keystoneFile getPrivateKeyPwd:keystonePwd FromPublicKey:[accountModel.owner.key_auths firstObject].key];
        CocosPrivateKey *activePri = [keystoneFile getPrivateKeyPwd:keystonePwd FromPublicKey:accountModel.options.memo_key];
        
        NSMutableDictionary *privateDic = [NSMutableDictionary dictionary];
        if (ownerPri) {
            privateDic[@"owner_key"] = [ownerPri description];
        }
        if (activePri) {
            privateDic[@"active_key"] = [activePri description];
        }
        // 4. Save to database
        if (isSaveInfo) {
            CocosDBAccountModel *dbWalletModel = [[CocosDBAccountModel alloc] init];
            dbWalletModel.name = accountModel.name;
            dbWalletModel.ID = [accountModel.identifier generateToTransferObject];
            dbWalletModel.keystone = keystone;
            dbWalletModel.walletMode = CocosWalletModeWallet;
            dbWalletModel.chainid = [CocosConfig chainId];
            dbWalletModel.chainname = [NSString stringWithFormat:@"%@%@",[CocosConfig chainId],accountModel.name];
            [[CocosDataBase Cocos_shareDatabase] Cocos_SaveAccountModel:dbWalletModel];
        }
        !successBlock?:successBlock(privateDic);
    } Error:errorBlock];
}
/** Verify that the password is correct */
- (void)validateAccount:(NSString *)accountName
               Password:(NSString *)password
                Success:(SuccessBlock)successBlock
                  Error:(Error)errorBlock
{
    // 1. Validation parameters
    if (IsStrEmpty(accountName) || IsStrEmpty(password)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ or ‘password‘ is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    NSString *active = @"active";
    NSString *activeSeed = [NSString stringWithFormat:@"%@%@%@",accountName,active,password];
    NSString *active_pubkey = [Cocos_Key_Account publicKey_with_seed:activeSeed];
    // 2. Account Password Verification
    [self getKeyReferences:active_pubkey Success:^(NSArray *responseObject) {
        NSArray *result = responseObject.firstObject;
        if (result.count) {
            // 2.1 Verify that the password is correct and generate private key transfer
            NSString *active_key = [Cocos_Key_Account private_with_seed:activeSeed];
            NSString *owner = @"owner";
            NSString *ownerSeed = [NSString stringWithFormat:@"%@%@%@",accountName,owner,password];
            NSString *owner_key = [Cocos_Key_Account private_with_seed:ownerSeed];
            NSMutableDictionary *privateDic = [NSMutableDictionary dictionary];
            privateDic[@"owner_key"] = owner_key;
            privateDic[@"active_key"] = active_key;
            !successBlock?:successBlock(privateDic);
        }else{
            // 2.2 Decrypt the private key as a temporary password
            [self Cocos_GetPrivateWithName:accountName Password:password Success:successBlock Error:errorBlock];
        }
    } Error:errorBlock];
}

/** Save account information */
- (void)SaveAccountInfo:(NSString *)accountName
           isNewAccount:(BOOL)newAccount
           OwnerPrivate:(NSString *)ownerPrivate
          ActivePrivate:(NSString *)activePrivate
               Password:(NSString *)password
             WalletMode:(CocosWalletMode)walletMode
                Success:(SuccessBlock)successBlock
                  Error:(Error)errorBlock
{
    if (newAccount) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t disp = dispatch_semaphore_create(0);
            do {
                [self Cocos_GetAccount:accountName Success:^(id account) {
                    // 主线程回调
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self acountThenSaveWithAccount:accountName accountInfo:account OwnerPrivate:ownerPrivate ActivePrivate:activePrivate Password:password WalletMode:walletMode Success:successBlock Error:errorBlock];
                    });
                } Error:^(NSError *error) {
                    dispatch_semaphore_signal(disp);
                }];
                // 2. 等待信号
                dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
            } while (1);
        });
    }else{
        // 1. Query account information
        [self Cocos_GetAccount:accountName Success:^(id account) {
            [self acountThenSaveWithAccount:accountName accountInfo:account OwnerPrivate:ownerPrivate ActivePrivate:activePrivate Password:password WalletMode:walletMode Success:successBlock Error:errorBlock];
        } Error:errorBlock];
    }
}

- (void)acountThenSaveWithAccount:(NSString *)accountName
                      accountInfo:(id)account
                     OwnerPrivate:(NSString *)ownerPrivate
                    ActivePrivate:(NSString *)activePrivate
                         Password:(NSString *)password
                       WalletMode:(CocosWalletMode)walletMode
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:account];
    KeystoneFile *keystone = [[KeystoneFile alloc] init];
    BOOL ActivekeyStoneBool = YES;
    BOOL OwnerkeyStoneBool = YES;
    if (ownerPrivate) {
        CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:ownerPrivate];
        OwnerkeyStoneBool = [keystone importKey:private ForAccount:accountModel];
    }
    if (activePrivate) {
        CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:activePrivate];
        ActivekeyStoneBool = [keystone importKey:private ForAccount:accountModel];
    }
    [keystone lockKeyWithString:password];
    
    if (OwnerkeyStoneBool && ActivekeyStoneBool) {
        // 2. Encrypted private key preservation
        CocosDBAccountModel *dbWalletModel = [[CocosDBAccountModel alloc] init];
        dbWalletModel.name = accountModel.name;
        dbWalletModel.ID = [accountModel.identifier generateToTransferObject];
        NSDictionary *keystoneDic = [keystone generateToTransferObject];
        NSData *keystoneData = [NSJSONSerialization dataWithJSONObject:keystoneDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *keystoneString = [[NSString alloc]initWithData:keystoneData encoding:NSUTF8StringEncoding];;
        NSMutableString *mutStr = [NSMutableString stringWithString:keystoneString];
        NSRange range2 = {0,mutStr.length};
        //去掉字符串中的换行符
        [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
        dbWalletModel.keystone = keystoneString;
        dbWalletModel.walletMode = walletMode;
        dbWalletModel.chainid = [CocosConfig chainId];
        dbWalletModel.chainname = [NSString stringWithFormat:@"%@%@",[CocosConfig chainId],accountModel.name];
        [[CocosDataBase Cocos_shareDatabase] Cocos_SaveAccountModel:dbWalletModel];
        !successBlock?:successBlock(accountModel.name);
    }else{
        NSError *error = [NSError errorWithDomain:@"Private key is not owner by account name" code:SDKErrorCodeAccountNameError userInfo:@{@"accountName":accountName}];
        !errorBlock?:errorBlock(error);
    }
}

// Decrypt Private Key Transfer
- (void)transferFromAccount:(NSString *)fromName
                  toAccount:(NSString *)toName
              activePrivate:(CocosPrivateKey *)private
              transferAsset:(NSString *)transferAsset
                assetAmount:(NSString *)assetAmount
             feePayingAsset:(NSString *)feePayingAsset
                       memo:(NSString *)memo
                    Success:(SuccessBlock)successBlock
                      Error:(Error)errorBlock
{
    
    // 1. Query Transfer object information
    [self getTransferObjFromAccount:fromName toAccount:toName activePrivate:private transferAsset:transferAsset feePayingAsset:feePayingAsset memo:memo Success:^(NSDictionary *operationObj) {
        ChainAccountModel *fromModel = operationObj[@"fromModel"];
        ChainAccountModel *toModel = operationObj[@"toModel"];
        ChainAssetObject *assetModel = operationObj[@"assetModel"];
        ChainAssetObject *feeAssetModel = operationObj[@"feeAssetModel"];
        ChainMemo *memoData = operationObj[@"memoData"];
        
        // 2. Stitching transfer data
        CocosTransferOperation *operation = [[CocosTransferOperation alloc] init];
        operation.from = fromModel.identifier;
        operation.to = toModel.identifier;
        operation.amount = [assetModel getAmountFromNormalFloatString:[NSString stringWithFormat:@"%@",assetAmount]];
        operation.requiredAuthority = fromModel.active.publicKeys;
        if (memoData) {
            operation.memo = memoData;
        }
        // 3. Inquiry fee
        [self Cocos_OperationFees:operation OperationType:0 FeePayingAsset:feeAssetModel.identifier.generateToTransferObject Success:^(NSArray * feeObject) {
            // 4. Stitching fee
            NSDictionary *feeDic = feeObject.firstObject;
            operation.fee = [ChainAssetAmountObject generateFromObject:feeDic];
            CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
            SignedTransaction *signedTran = [[SignedTransaction alloc] init];
            signedTran.operations = @[content];
            // 5. Transfer
            [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/** Request object for operation */
- (void)getOperationFromAccount:(NSString *)fromName
                      toAccount:(NSString *)toName
                 feePayingAsset:(NSString *)feePayingAsset
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock
{
    [self Cocos_GetAccount:fromName Success:^(id fromAccount) {
        ChainAccountModel *fromModel =[ChainAccountModel generateFromObject:fromAccount];
        // 2. Inquiry for payee information
        [self Cocos_GetAccount:toName Success:^(id toAccount) {
            ChainAccountModel *toModel =[ChainAccountModel generateFromObject:toAccount];
            // 3. Search for asset information
            [self Cocos_GetAsset:feePayingAsset Success:^(id feeAssetObject) {
                ChainAssetObject *feeAssetModel = [ChainAssetObject generateFromObject:feeAssetObject];
                // 4. Return the desired object
                NSMutableDictionary *operationObj = [NSMutableDictionary dictionary];
                operationObj[@"fromModel"] = fromModel;
                operationObj[@"toModel"] = toModel;
                operationObj[@"feeAssetModel"] = feeAssetModel;
                !successBlock?:successBlock(operationObj);
            } Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/** Request object for transfer */
- (void)getTransferObjFromAccount:(NSString *)fromName
                        toAccount:(NSString *)toName
                    activePrivate:(CocosPrivateKey *)private
                    transferAsset:(NSString *)transferAsset
                   feePayingAsset:(NSString *)feePayingAsset
                             memo:(NSString *)memo
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    // 1. Inquiry for transferor information
    [self Cocos_GetAccount:fromName Success:^(id fromAccount) {
        ChainAccountModel *fromModel =[ChainAccountModel generateFromObject:fromAccount];
        // 2. Inquiry for payee information
        [self Cocos_GetAccount:toName Success:^(id toAccount) {
            ChainAccountModel *toModel =[ChainAccountModel generateFromObject:toAccount];
            // 3. Search for asset information
            [self Cocos_GetAsset:transferAsset Success:^(id assetObject) {
                ChainAssetObject *assetModel = [ChainAssetObject generateFromObject:assetObject];
                ChainMemo *memoData = nil;
                if (memo.length > 0) {
                    memoData = [[ChainMemo alloc] initWithPrivateKey:private anotherPublickKey:toModel.options.memo_key customerNonce:nil totalMessage:memo];
                }
                if ([transferAsset isEqualToString:feePayingAsset]) {
                    // 4. Return the desired object
                    NSMutableDictionary *operationObj = [NSMutableDictionary dictionary];
                    operationObj[@"fromModel"] = fromModel;
                    operationObj[@"toModel"] = toModel;
                    operationObj[@"assetModel"] = assetModel;
                    operationObj[@"feeAssetModel"] = assetModel;
                    operationObj[@"memoData"] = memoData;
                    !successBlock?:successBlock(operationObj);
                }else{
                    [self Cocos_GetAsset:feePayingAsset Success:^(id feeAssetObject) {
                        ChainAssetObject *feeAssetModel = [ChainAssetObject generateFromObject:feeAssetObject];
                        // 4. Return the desired object
                        NSMutableDictionary *operationObj = [NSMutableDictionary dictionary];
                        operationObj[@"fromModel"] = fromModel;
                        operationObj[@"toModel"] = toModel;
                        operationObj[@"assetModel"] = assetModel;
                        operationObj[@"feeAssetModel"] = feeAssetModel;
                        operationObj[@"memoData"] = memoData;
                        !successBlock?:successBlock(operationObj);
                    } Error:errorBlock];
                }
            } Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
}

/** signedTransaction */
- (void)signedTransaction:(SignedTransaction *)signedTransaction
            activePrivate:(CocosPrivateKey *)private
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock
{
    [self Cocos_GetDynamicGlobalPropertiesWithSuccess:^(id responseObject) {
        ChainDynamicGlobalProperties *result = [ChainDynamicGlobalProperties generateFromObject:responseObject];
        [signedTransaction setRefBlock:result.head_block_id];
        signedTransaction.expiration = [result.time dateByAddingTimeInterval:30];
        
        [signedTransaction signWithPrikey:private];
        
        UploadParams *uploadParams = [[UploadParams alloc] init];
        
        uploadParams.methodName = kCocosBroadcastTransaction;
        
        uploadParams.totalParams = @[signedTransaction.generateToTransferObject];
        
        CallBackModel *callBackModel = [[CallBackModel alloc] init];
        
        callBackModel.successResult = successBlock;
        
        callBackModel.errorResult = errorBlock;
        
        [self sendWithChainApi:WebsocketBlockChainApiNetworkBroadcast method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
        
    } Error:errorBlock];
}

/** Verify whether the public key is registered */
- (void)getKeyReferences:(NSString *)publicStr
                 Success:(SuccessBlock)successBlock
                   Error:(Error)errorBlock
{
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosGetKeyReferences;
    uploadParams.totalParams = @[@[publicStr]];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

- (void)sendWithChainApi:(WebsocketBlockChainApi)chainApi
                  method:(WebsocketBlockChainMethodApi)method
                  params:(UploadParams *)uploadParams
                callBack:(CallBackModel *)callBack
{
    [_client sendWithChainApi:chainApi method:method params:uploadParams callBack:callBack];
}

// Verify username validity
- (BOOL)regexAccountNameValidate:(NSString *)string {
    NSPredicate *myRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-z][a-z0-9.-]{3,63}$"];
    return [myRegex evaluateWithObject:string];
}
@end
