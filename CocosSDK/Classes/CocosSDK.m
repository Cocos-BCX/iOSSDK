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
#import "ChainVestingBalance.h"

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
    return @"2.0.0";
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
/**
 Query Current Chain ID
 */
- (void)Cocos_QueryCurrentChainID:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    // 1. Request account information with all wallet account IDs
    UploadParams *uploadParams = [[UploadParams alloc] init];
    uploadParams.methodName = kCocosGetChainId;
    uploadParams.totalParams = @[];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
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

/**
 ChangePassword Account mode
 
 @param account            Account
 @param oldpassword        oldpassword
 @param currentPassword    currentPassword
 */
- (void)Cocos_ChangePassword:(NSString *)account
                 OldPassword:(NSString *)oldpassword
             CurrentPassword:(NSString *)currentPassword
                     Success:(SuccessBlock)successBlock
                       Error:(Error)errorBlock
{
    // 1. account info
    [self Cocos_GetAccount:account Success:^(id responseObject) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
        // 2. valida password
        [self validateAccount:accountModel.name Password:oldpassword Success:^(NSDictionary *keyDic) {
            if (keyDic[@"owner_key"]){
                // 2. Declassified private key
                CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"owner_key"]];
                
                // 4. Stitching transfer data
                CocosUpdateAccountOperation *operation = [[CocosUpdateAccountOperation alloc] init];
                operation.lock_with_vote = nil;
                operation.account = accountModel.identifier;
                
                NSString *ownerSeed = [NSString stringWithFormat:@"%@owner%@",accountModel.name,currentPassword];
                NSString *activeSeed = [NSString stringWithFormat:@"%@active%@",accountModel.name,currentPassword];
                NSString *owner_pubkey = [Cocos_Key_Account publicKey_with_seed:ownerSeed];
                NSString *active_pubkey = [Cocos_Key_Account publicKey_with_seed:activeSeed];
                
                owner_pubkey = [owner_pubkey substringFromIndex:[CocosConfig prefix].length];
                active_pubkey = [active_pubkey substringFromIndex:[CocosConfig prefix].length];
                
                CocosPublicKey *active_pub = [[CocosPublicKey alloc] initWithPubkeyString:active_pubkey];
                CocosPublicKey *owner_pub = [[CocosPublicKey alloc] initWithPubkeyString:owner_pubkey];
                accountModel.active.key_auths = @[[[PublicKeyAuthorityObject alloc] initWithPublicKey:active_pub weightThreshold:1]];
                accountModel.owner.key_auths = @[[[PublicKeyAuthorityObject alloc] initWithPublicKey:owner_pub weightThreshold:1]];
                operation.active = accountModel.active;
                operation.owner = accountModel.owner;
                accountModel.options.memo_key = [accountModel.active.key_auths firstObject].key;
                operation.options = (VoteOptionsObject *)accountModel.options;
                
                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                signedTran.operations = @[content];
                // 7. Transfer
                [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                
            }else if (keyDic[@"active_key"]) {
                NSError *error = [NSError errorWithDomain:@"Please import the owner private key" code:SDKErrorCodePrivateisNull userInfo:nil];
                !errorBlock?:errorBlock(error);
            }else{
                NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":oldpassword}];
                !errorBlock?:errorBlock(error);
            }
        } Error:errorBlock];
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
 */
- (void)Cocos_UpgradeMemberAccount:(NSString *)account
                          password:(NSString *)password
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
                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                signedTran.operations = @[content];
                // 7. Transfer
                [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
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
 CreateSonAccount
 
 @param newAccountName SonAccount
 @param newPassword SonPassword
 @param account account
 @param password password
 */
- (void)Cocos_CreateSonAccount:(NSString *)newAccountName
                   newPassword:(NSString *)newPassword
                     Registrar:(NSString *)account
                      password:(NSString *)password
                       Success:(SuccessBlock)successBlock
                         Error:(Error)errorBlock
{
    // 1.1 Validation parameters
    if (IsStrEmpty(newAccountName) || IsStrEmpty(newPassword)) {
        NSError *error = [NSError errorWithDomain:@"Parameter ‘accountName‘ or ‘password‘  is missing" code:SDKErrorCodeErrorParameterError userInfo:nil];
        !errorBlock?:errorBlock(error);
        return;
    }
    
    // 1.2 Verify Account Name
    if (![self regexAccountNameValidate:newAccountName]) {
        NSError *error = [NSError errorWithDomain:@"Please enter the correct account name(/^a-z{4,63}/$)" code:SDKErrorCodeAccountNameError userInfo:@{@"account":newAccountName}];
        !errorBlock?:errorBlock(error);
        return;
    }
    // 2. Generating parameters
    NSString *owner = @"owner";
    NSString *active = @"active";
    NSString *ownerSeed = [NSString stringWithFormat:@"%@%@%@",newAccountName,owner,newPassword];
    NSString *activeSeed = [NSString stringWithFormat:@"%@%@%@",newAccountName,active,newPassword];
    NSString *owner_key = [Cocos_Key_Account private_with_seed:ownerSeed];
    NSString *active_key = [Cocos_Key_Account private_with_seed:activeSeed];
    NSString *owner_pubkey = [Cocos_Key_Account publicKey_with_seed:ownerSeed];
    NSString *active_pubkey = [Cocos_Key_Account publicKey_with_seed:activeSeed];
    // 1. Account password decryption
    [self validateAccount:account Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            // 3. account info
            [self Cocos_GetAccount:account Success:^(id responseObject) {
                ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
                
                NSDictionary *ownerAuthDic = @{
                                               @"weight_threshold":@(1),
                                               @"account_auths":@[],
                                               @"key_auths":@[@[owner_pubkey,@(1)]],
                                               @"address_auths":@[]
                                               };
                AuthorityObject *ownerAuthoriry = [AuthorityObject generateFromObject:ownerAuthDic];
                
                NSDictionary *activeAuthDic = @{
                                                @"weight_threshold":@(1),
                                                @"account_auths":@[],
                                                @"key_auths":@[@[active_pubkey,@(1)]],
                                                @"address_auths":@[]
                                                };
                AuthorityObject *activeAuthoriry = [AuthorityObject generateFromObject:activeAuthDic];
                
                NSDictionary *optionsDic = @{
                                             @"memo_key":active_pubkey,
                                             @"votes":@[],
                                             @"extensions":@[]
                                             };
                AccountOptionObject *optionAuthoriry = [AccountOptionObject generateFromObject:optionsDic];
                
                // 4. Stitching transfer data
                CocosCreateSonAccountOperation *operation = [[CocosCreateSonAccountOperation alloc] init];
                operation.registrar = accountModel.identifier;
                operation.name = newAccountName;
                operation.owner = ownerAuthoriry;
                operation.active = activeAuthoriry;
                operation.options = optionAuthoriry;
                // 5. Inquiry fee
                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                signedTran.operations = @[content];
                // 7. Transfer
                [self signedTransaction:signedTran activePrivate:private Success:^(id responseObject) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    dic[@"active_pri_key"] = active_key;
                    dic[@"owner_pri_key"] = owner_key;
                    dic[@"active_pub_key"] = active_pubkey;
                    dic[@"owner_pub_key"] = owner_pubkey;
                    dic[@"accont_name"] = newAccountName;
                    !successBlock?:successBlock(dic);
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

/** Transfer */
- (void)Cocos_TransferFromAccount:(NSString *)fromName
                        ToAccount:(NSString *)toName
                         Password:(NSString *)password
                    TransferAsset:(NSString *)transferAsset
                      AssetAmount:(NSString *)assetAmount
                 IsEncryptionMemo:(BOOL)encryption
                             Memo:(NSString *)memo
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:fromName Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            [self transferFromAccount:fromName toAccount:toName activePrivate:private transferAsset:transferAsset assetAmount:assetAmount IsEncryptionMemo:encryption memo:memo Success:successBlock Error:errorBlock];
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

/** Call contract */
- (void)Cocos_CallContract:(NSString *)contractIdOrName
       ContractMethodParam:(NSArray *)param
            ContractMethod:(NSString *)contractmMethod
             CallerAccount:(NSString *)accountIdOrName
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
    uploadParams.totalParams = @[accountID,@"",@(pageSize),@(page)];
    CallBackModel *callBackModel = [[CallBackModel alloc] init];
    callBackModel.successResult = successBlock;
    callBackModel.errorResult = errorBlock;
    [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
}

/** assets transfer */
- (void)Cocos_TransferNHAsset:(NSString *)from
                    ToAccount:(NSString *)to
                    NHAssetID:(NSString *)NHAssetID
                     Password:(NSString *)password
                      Success:(SuccessBlock)successBlock
                        Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:from Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            [self getOperationFromAccount:from toAccount:to Success:^(NSDictionary *operationObj) {
                ChainAccountModel *fromModel = operationObj[@"fromModel"];
                ChainAccountModel *toModel = operationObj[@"toModel"];
                // 2. Stitching transfer data
                CocosTransferNHOperation *operation = [[CocosTransferNHOperation alloc] init];
                operation.from = fromModel.identifier;
                operation.to = toModel.identifier;
                operation.nh_asset = [ChainObjectId createFromString:NHAssetID];
                operation.requiredAuthority = fromModel.active.publicKeys;
                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                signedTran.operations = @[content];
                // 5. Transfer
                [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
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
 Buy NH assets
 */
- (void)Cocos_BuyNHAssetOrderID:(NSString *)orderID
                        Account:(NSString *)account
                       Password:(NSString *)password
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
                        CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                        SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                        signedTran.operations = @[content];
                        // 8. Call contract
                        [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
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

/** Delete NH assets */
- (void)Cocos_DeleteNHAssetAccount:(NSString *)account
                          Password:(NSString *)password
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
                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                signedTran.operations = @[content];
                // 7. Delete
                [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
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

/** cancel sell NH assets */
- (void)Cocos_CancelNHAssetAccount:(NSString *)account
                          Password:(NSString *)password
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
                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                signedTran.operations = @[content];
                // 7. Delete
                [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
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
                CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                signedTran.operations = @[content];
                // 3. Sell
                [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
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

/** estimation gas */
- (void)Cocos_Gas_EstimationWithCOCOSAmout:(NSString *)amount
                                   Success:(SuccessBlock)successBlock
                                     Error:(Error)errorBlock
{
    [self Cocos_GetAsset:@"1.3.0" Success:^(id affectedRes) {
        ChainAssetObject *affectedModel = [ChainAssetObject generateFromObject:affectedRes];
        UploadParams *uploadParams = [[UploadParams alloc] init];
        uploadParams.methodName = kCocosEstimationGas;
        ChainAssetAmountObject *chainAssetAmount = [affectedModel getAmountFromNormalFloatString:amount];
        uploadParams.totalParams = @[[chainAssetAmount generateToTransferObject]];
        CallBackModel *callBackModel = [[CallBackModel alloc] init];
        callBackModel.successResult = successBlock;
        callBackModel.errorResult = errorBlock;
        [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
    } Error:errorBlock];
}

/** mortgager gas */
- (void)Cocos_GasWithMortgager:(NSString *)mortgagerAccount
                   Beneficiary:(NSString *)beneficiaryAccount
                    Collateral:(long)collateral
                      Password:(NSString *)password
                       Success:(SuccessBlock)successBlock
                         Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:mortgagerAccount Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            [self Cocos_GetAccount:mortgagerAccount Success:^(id mortgagerRes) {
                ChainAccountModel *mortgager =[ChainAccountModel generateFromObject:mortgagerRes];
                
                [self Cocos_GetAccount:beneficiaryAccount Success:^(id beneficiaryRes) {
                    ChainAccountModel *beneficiary =[ChainAccountModel generateFromObject:beneficiaryRes];
                    
                    CocosMortgageGasOperation *operation = [[CocosMortgageGasOperation alloc] init];
                    operation.mortgager = mortgager.identifier;
                    operation.beneficiary = beneficiary.identifier;
                    operation.collateral = collateral*100000;
                    operation.requiredAuthority = mortgager.active.publicKeys;
                    CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                    SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                    signedTran.operations = @[content];
                    // 3. Transfer
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

- (NSDictionary *)handleVestingBalance:(NSDictionary *)vestingbalance
{
    
    ChainVestingBalance *vesting = [ChainVestingBalance generateFromObject:vestingbalance];
    // balance key
    ChainAssetAmountObject *gasBalance = vesting.balance;
    long return_cash = gasBalance.amount;;
    
    // policy key
    ChainVestingBalancePolicy *gasPolicy = [ChainVestingBalancePolicy generateFromObject:[vesting.policy lastObject]];
    
    // current date
    NSInteger currentTimeInteger = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue];
    
    // 服务器时间戳
    NSInteger timeSp = ({
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 获得日期对象
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [formatter setTimeZone:timeZone];
        NSDate *createDate = [formatter dateFromString:gasPolicy.coin_seconds_earned_last_update];
        
        // 获取系统时区
        NSTimeZone *zone1 = [NSTimeZone systemTimeZone];
        [formatter setTimeZone:zone1];
        NSString *formatTime = [formatter stringFromDate:createDate];
        NSDate* date = [formatter dateFromString:formatTime];
        //时间转时间戳的方法:
        NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
        timeSp;
    });
    // 相差秒数
    NSInteger past_sconds = currentTimeInteger - timeSp;
    
    float vesting_seconds = gasPolicy.vesting_seconds;
    float total_earned = vesting_seconds * return_cash;
    float new_earned = (past_sconds / vesting_seconds)*(total_earned);
    float old_earned = gasPolicy.coin_seconds_earned;
    float earned = old_earned + new_earned;
    float availablePercent = 0;
    if (return_cash == 0) {
        availablePercent = 0;
    }else {
        availablePercent = (earned / (vesting_seconds * return_cash) > 1)?1:earned / (vesting_seconds * return_cash);
    }
    long available_balance_amount = (long)(availablePercent * return_cash);//精度
    float remaining_hours = vesting_seconds * (1 - availablePercent)/3600;

    return @{
             @"available_balance_amount":[NSNumber numberWithLong:available_balance_amount],
             @"remaining_hours":[NSNumber numberWithFloat:remaining_hours],
             @"return_cash":[NSNumber numberWithLong:return_cash],
             @"availablePercent":[NSNumber numberWithFloat:availablePercent]
             };
}

/** lookup Block Rewards */
- (void)Cocos_QueryVestingBalance:(NSString *)account
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock
{
    [self Cocos_GetVestingBalances:account Success:^(NSArray * result) {
        
        NSMutableArray *vestingArray = [NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t disp = dispatch_semaphore_create(0);
            for (NSDictionary *vestingbalance in result) {
                ChainVestingBalance *vesting = [ChainVestingBalance generateFromObject:vestingbalance];
                // balance key
                ChainAssetAmountObject *gasBalance = vesting.balance;
                
                NSDictionary *vestingBalance = [self handleVestingBalance:vestingbalance];
                long return_cash = [vestingBalance[@"return_cash"] longValue];
                long available_balance_amount = [vestingBalance[@"available_balance_amount"] longValue];
                float remaining_hours = [vestingBalance[@"remaining_hours"] floatValue];
                float availablePercent = [vestingBalance[@"availablePercent"] floatValue];
                
                [self Cocos_GetAsset:[gasBalance.assetId generateToTransferObject] Success:^(id responseObject) {
                    ChainAssetObject *opAssetModel = [ChainAssetObject generateFromObject:responseObject];
                    
                    NSDecimalNumber *amount_demicimal = [NSDecimalNumber decimalNumberWithMantissa:available_balance_amount exponent:-opAssetModel.precision isNegative:NO];
                    
                    NSDecimalNumber *return_cash_demicimal = [NSDecimalNumber decimalNumberWithMantissa:return_cash exponent:-opAssetModel.precision isNegative:NO];
                    
                    NSMutableDictionary *successData = [NSMutableDictionary dictionary];
                    successData[@"type"] = vesting.describe;
                    successData[@"id"] = [vesting.identifier generateToTransferObject];
                    successData[@"return_cash"] = return_cash_demicimal.stringValue;
                    successData[@"available_percent"] = @(availablePercent*100);
                    successData[@"remaining_hours"] = @(remaining_hours);
                    
                    successData[@"available_balance"] = @{
                        @"amount":amount_demicimal.stringValue,
                        @"asset_id":[opAssetModel.identifier generateToTransferObject],
                        @"symbol":opAssetModel.symbol,
                        @"precision":@(opAssetModel.precision)
                    };
                    [vestingArray addObject:successData];
                    // 释放信号
                    dispatch_semaphore_signal(disp);
                } Error:errorBlock];
                // 2. 等待信号
                dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
            }
           
            dispatch_async(dispatch_get_main_queue(), ^{
                if (vestingArray.count) {
                    NSDictionary *successDic = @{
                        @"code":@(1),
                        @"data":vestingArray
                    };
                    !successBlock?:successBlock(successDic);
                }else{
                    NSError *error = [NSError errorWithDomain:@"No reward available" code:SDKErrorNoRewardAvailable userInfo:@{@"account":account}];
                    !errorBlock?:errorBlock(error);
                }
                           
            });
        });
    } Error:errorBlock];
}

/** get_vesting_balances */
- (void)Cocos_GetVestingBalances:(NSString *)account
                         Success:(SuccessBlock)successBlock
                           Error:(Error)errorBlock
{
    [self Cocos_GetAccount:account Success:^(id accountRes) {
        ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:accountRes];
        UploadParams *uploadParams = [[UploadParams alloc] init];
        uploadParams.methodName = kCocosGetVestingBalances;
        uploadParams.totalParams = @[[accountModel.identifier generateToTransferObject]];
        CallBackModel *callBackModel = [[CallBackModel alloc] init];
        callBackModel.successResult = successBlock;
        callBackModel.errorResult = errorBlock;
        [self sendWithChainApi:WebsocketBlockChainApiDataBase method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBackModel];
    } Error:errorBlock];
}

/**
 claim vesting balance
 @param account account
 @param password password
 */
- (void)Cocos_ClaimVestingBalance:(NSString *)account
                         Password:(NSString *)password
                        VestingID:(NSString *)vesting_id
                          Success:(SuccessBlock)successBlock
                            Error:(Error)errorBlock
{
    // 1. Account password decryption
    [self validateAccount:account Password:password Success:^(NSDictionary *keyDic) {
        if (keyDic[@"active_key"]) {
            
            // 2. Generating Private Key Transfer
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"active_key"]];
            
            [self Cocos_GetAccount:account Success:^(id accountRes) {
                ChainAccountModel *ownerAccount =[ChainAccountModel generateFromObject:accountRes];
                [self Cocos_GetVestingBalances:account Success:^(NSArray * result) {
                    for (int i = 0 ; i<result.count; i++) {
                        NSDictionary *vestingDic = result[i];
                        ChainVestingBalance *vestingbalance = [ChainVestingBalance generateFromObject:vestingDic];
                        
                        if ([vestingbalance.identifier.description isEqualToString:vesting_id]) {
                            CocosClaimVestingBalanceOperation *operation = [[CocosClaimVestingBalanceOperation alloc] init];
                            operation.vesting_balance = [ChainObjectId createFromString:vesting_id];
                            operation.owner = ownerAccount.identifier;
                            NSDictionary *vestingBalance = [self handleVestingBalance:vestingDic];
                            long available_balance_amount = [vestingBalance[@"available_balance_amount"] longValue];
                            
                            ChainAssetAmountObject *amount = [[ChainAssetAmountObject alloc] initFromAssetId:vestingbalance.balance.assetId amount:available_balance_amount];
                            operation.amount = amount;
                            operation.requiredAuthority = ownerAccount.active.publicKeys;
                            CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
                            SignedTransaction *signedTran = [[SignedTransaction alloc] init];
                            signedTran.operations = @[content];
                            // 3. Transfer
                            [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
                            break;
                        }
                    }
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


#pragma mark - Committee Member Witnesses Vote
//typedef NS_ENUM(int,VoteIdType) {
//    VoteIdTypeCommitteeMember,// 理事会
//    VoteIdTypeWitness,见证人
//};
/** Get CommitteeMember Info: Active、Vote*/
- (void)Cocos_GetCommitteeMemberInfoVoteAccountId:(NSString *)account_id
                                          Success:(SuccessBlock)successBlock
                                            Error:(Error)errorBlock
{
    [self Cocos_GetObjects:@[@"2.0.0"] Success:^(NSArray *global_data) {
        NSDictionary *active_committee_dic = [global_data firstObject];
        NSArray *activeArray = active_committee_dic[@"active_committee_members"];
        
        NSArray *memberIDArray = @[@"1.5.0",@"1.5.1",@"1.5.2",@"1.5.3",@"1.5.4",@"1.5.5",@"1.5.6",@"1.5.7",@"1.5.8",@"1.5.9",@"1.5.10",@"1.5.11",@"1.5.12",@"1.5.13",@"1.5.14",@"1.5.15",@"1.5.16",@"1.5.17",@"1.5.18",@"1.5.19",@"1.5.20",@"1.5.21",@"1.5.22",@"1.5.23",@"1.5.24",@"1.5.25",@"1.5.26",@"1.5.27",@"1.5.28",@"1.5.29",@"1.5.30",@"1.5.31",@"1.5.32",@"1.5.33",@"1.5.34",@"1.5.35",@"1.5.36",@"1.5.37",@"1.5.38",@"1.5.39",@"1.5.40",@"1.5.41",@"1.5.42",@"1.5.43",@"1.5.44",@"1.5.45",@"1.5.46",@"1.5.47",@"1.5.48",@"1.5.49",@"1.5.50"];
        [self Cocos_GetObjects:memberIDArray Success:^(NSArray *responsArray) {
            NSMutableArray *memberArray = [NSMutableArray array];
            // 开启遍历
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_semaphore_t disp = dispatch_semaphore_create(0);
                for (id obj in responsArray) {
                    if ([obj isEqual:[NSNull null]]) {
                        break;
                    }else{
                        NSMutableDictionary *objDictionary = [NSMutableDictionary dictionary];
                        objDictionary[@"url"] = obj[@"url"];
                        objDictionary[@"account_id"] = obj[@"committee_member_account"];
                        objDictionary[@"vote_id"] = obj[@"vote_id"];
                        objDictionary[@"committee_id"] = obj[@"id"];
                        objDictionary[@"type"] = @"committee";
                        
                        // 票数，COCOS 五位小数
                        objDictionary[@"votes"] = [NSString stringWithFormat:@"%.3f",[obj[@"total_votes"] integerValue]/100000.000];
                        NSArray *supporterArray = obj[@"supporters"];
                        
                        NSMutableArray *supportArray = [NSMutableArray array];
                        for (NSArray *support in supporterArray) {
                            NSMutableDictionary *supportDic = [NSMutableDictionary dictionary];
                            supportDic[@"account_id"] = [support firstObject];
                            NSDictionary *support_asset =  [support lastObject];
                            supportDic[@"amount_raw"] = support_asset;
                            supportDic[@"amount_text"] = [NSString stringWithFormat:@"%.3f COCOS",[support_asset[@"amount"] integerValue]/100000.000];
                            [supportArray addObject:supportDic];
                        }
                        
                        objDictionary[@"supporters"] = supportArray;
                        // 投票人
                        NSMutableArray *supportidArray = [NSMutableArray array];
                        [supporterArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [supportidArray addObject:[obj firstObject]];
                        }];
                        // 是否活跃，是否是支持者
                        objDictionary[@"supported"] = @(NO);
                        objDictionary[@"active"] = @(NO);
                        if ([activeArray containsObject:obj[@"id"]]) {
                            objDictionary[@"active"] = @(YES);
                        }
                        if ([supportidArray containsObject:account_id]) {
                            objDictionary[@"supported"] = @(YES);
                        }
                        
                        [self Cocos_GetAccount:obj[@"committee_member_account"] Success:^(id accountObject) {
                            ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:accountObject];
                            objDictionary[@"account_name"] = accountModel.name;
                            [memberArray addObject:objDictionary];
                            dispatch_semaphore_signal(disp);
                        } Error:errorBlock];
                    }
                    // 2. 等待信号
                    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    !successBlock?:successBlock(memberArray);
                });
            });
        } Error:errorBlock];
    } Error:errorBlock];
}

/** Get Witness Info: Active、Vote*/
- (void)Cocos_GetWitnessInfoVoteAccountId:(NSString *)account_id
                                  Success:(SuccessBlock)successBlock
                                    Error:(Error)errorBlock
{
    [self Cocos_GetObjects:@[@"2.0.0"] Success:^(NSArray *global_data) {
        NSDictionary *active_committee_dic = [global_data firstObject];
        NSArray *activeArray = active_committee_dic[@"active_witnesses"];
        
        NSArray *memberIDArray = @[@"1.6.1",@"1.6.2",@"1.6.3",@"1.6.4",@"1.6.5",@"1.6.6",@"1.6.7",@"1.6.8",@"1.6.9",@"1.6.10",@"1.6.11",@"1.6.12",@"1.6.13",@"1.6.14",@"1.6.15",@"1.6.16",@"1.6.17",@"1.6.18",@"1.6.19",@"1.6.20",@"1.6.21",@"1.6.22",@"1.6.23",@"1.6.24",@"1.6.25",@"1.6.26",@"1.6.27",@"1.6.28",@"1.6.29",@"1.6.30",@"1.6.31",@"1.6.32",@"1.6.33",@"1.6.34",@"1.6.35",@"1.6.36",@"1.6.37",@"1.6.38",@"1.6.39",@"1.6.40",@"1.6.41",@"1.6.42",@"1.6.43",@"1.6.44",@"1.6.45",@"1.6.46",@"1.6.47",@"1.6.48",@"1.6.49",@"1.6.50"];
        [self Cocos_GetObjects:memberIDArray Success:^(NSArray *responsArray) {
            NSMutableArray *memberArray = [NSMutableArray array];
            // 开启遍历
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_semaphore_t disp = dispatch_semaphore_create(0);
                for (id obj in responsArray) {
                    if ([obj isEqual:[NSNull null]]) {
                        break;
                    }else{
                        NSMutableDictionary *objDictionary = [NSMutableDictionary dictionary];
                        objDictionary[@"url"] = obj[@"url"];
                        objDictionary[@"account_id"] = obj[@"witness_account"];
                        objDictionary[@"type"] = @"witness";
                        objDictionary[@"vote_id"] = obj[@"vote_id"];
                        objDictionary[@"witness_id"] = obj[@"id"];
                        objDictionary[@"last_confirmed_block_num"] = obj[@"last_confirmed_block_num"];
                        objDictionary[@"total_missed"] = obj[@"total_missed"];
                        objDictionary[@"last_aslot"] = obj[@"last_aslot"];
                        
                        // 票数，COCOS 五位小数
                        objDictionary[@"votes"] = [NSString stringWithFormat:@"%.3f",[obj[@"total_votes"] integerValue]/100000.000];
                        // 投票人
                        NSArray *supporterArray = obj[@"supporters"];
                        NSMutableArray *supportArray = [NSMutableArray array];
                        for (NSArray *support in supporterArray) {
                            NSMutableDictionary *supportDic = [NSMutableDictionary dictionary];
                            supportDic[@"account_id"] = [support firstObject];
                            NSDictionary *support_asset =  [support lastObject];
                            supportDic[@"amount_raw"] = support_asset;
                            supportDic[@"amount_text"] = [NSString stringWithFormat:@"%.3f COCOS",[support_asset[@"amount"] integerValue]/100000.000];
                            [supportArray addObject:supportDic];
                        }
                        objDictionary[@"supporters"] = supportArray;
                        
                        NSMutableArray *supportidArray = [NSMutableArray array];
                        [supporterArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [supportidArray addObject:[obj firstObject]];
                        }];
                        // 是否活跃，是否是支持者
                        objDictionary[@"supported"] = @(NO);
                        objDictionary[@"active"] = @(NO);
                        if ([activeArray containsObject:obj[@"id"]]) {
                            objDictionary[@"active"] = @(YES);
                        }
                        if ([supportidArray containsObject:account_id]) {
                            objDictionary[@"supported"] = @(YES);
                        }
                        
                        [self Cocos_GetAccount:obj[@"witness_account"] Success:^(id accountObject) {
                            ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:accountObject];
                            objDictionary[@"account_name"] = accountModel.name;
                            [memberArray addObject:objDictionary];
                            dispatch_semaphore_signal(disp);
                        } Error:errorBlock];
                    }
                    // 2. 等待信号
                    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    !successBlock?:successBlock(memberArray);
                });
            });
        } Error:errorBlock];
    } Error:errorBlock];
}

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
                     Error:(Error)errorBlock
{
    // 1. Validation parameters
    [self validateAccount:accountName Password:password Success:^(NSDictionary *keyDic) {
       if (keyDic[@"owner_key"]){
            // 2. Declassified private key
            CocosPrivateKey *private = [[CocosPrivateKey alloc] initWithPrivateKey:keyDic[@"owner_key"]];
            
            // 1. query committeeIds
            NSMutableArray *vote_ids = [NSMutableArray array];
            NSMutableArray *vote_account_ids = [NSMutableArray array];
            [self Cocos_GetObjects:voteids Success:^(NSArray *idRes) {
                for (NSDictionary *response in idRes) {
                    if (type == 1) {
                        NSArray *committee = response[@"witness_status"];
                        [vote_account_ids addObject:[committee firstObject]];
                    }else{
                        NSArray *committee = response[@"committee_status"];
                        [vote_account_ids addObject:[committee firstObject]];
                    }
                }
                // 3. query vote
                [self Cocos_GetObjects:vote_account_ids Success:^(NSArray *voteIdArray) {
                    for (NSDictionary *voids in voteIdArray) {
                        [vote_ids addObject:voids[@"vote_id"]];
                    }
                    NSArray *sortVoteIds = [vote_ids sortedArrayUsingComparator:
                                            ^NSComparisonResult(NSString *obj1, NSString *obj2) {
                        // 排序
                        NSString *obj1id = [[obj1 componentsSeparatedByString:@":"] lastObject];
                        NSString *obj2id = [[obj2 componentsSeparatedByString:@":"] lastObject];
                        if ([obj1id integerValue] > [obj2id integerValue]) {
                            return NSOrderedDescending;
                        } else if ([obj1id integerValue] < [obj2id integerValue]) {
                            return NSOrderedAscending;
                        }
                        return NSOrderedSame;
                    }];
                    [self PublishVotes:accountName VoteIds:sortVoteIds Votes:votes Type:@(type) Private:private Success:successBlock Error:errorBlock];
                } Error:errorBlock];
            } Error:errorBlock];
        }else if (keyDic[@"active_key"]) {
            NSError *error = [NSError errorWithDomain:@"Please import the owner private key" code:SDKErrorCodePrivateisNull userInfo:nil];
            !errorBlock?:errorBlock(error);
        }else{
            NSError *error = [NSError errorWithDomain:@"Please enter the correct original/temporary password" code:SDKErrorCodePasswordwrong userInfo:@{@"password":password}];
            !errorBlock?:errorBlock(error);
        }
    } Error:errorBlock];
}

/** Votes : 0 > CommitteeMember,1 > Witness */
- (void)PublishVotes:(NSString *)accountName
             VoteIds:(NSArray *)voteids
               Votes:(NSString *)votes
                Type:(NSNumber *)type
             Private:(CocosPrivateKey *)private
             Success:(SuccessBlock)successBlock
               Error:(Error)errorBlock
{
    // 3. account info
    [self Cocos_GetAsset:@"COCOS" Success:^(id assetObject) {
        ChainAssetObject *voteAssetModel = [ChainAssetObject generateFromObject:assetObject];
        ChainAssetAmountObject *voteAmout = [voteAssetModel getAmountFromNormalFloatString:votes];
        
        [self Cocos_GetAccount:accountName Success:^(id responseObject) {
            ChainAccountModel *accountModel =[ChainAccountModel generateFromObject:responseObject];
            
            // 4. Stitching transfer data
            CocosUpdateAccountOperation *operation = [[CocosUpdateAccountOperation alloc] init];
            operation.lock_with_vote = @[type,voteAmout];
            operation.account = accountModel.identifier;
            VoteOptionsObject *voteOptions = [[VoteOptionsObject alloc] init];
            voteOptions.memo_key = [accountModel.active.key_auths firstObject].key;
            voteOptions.votes = voteids;
            operation.active = nil;
            operation.owner = nil;
            operation.options = voteOptions;
            CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
            SignedTransaction *signedTran = [[SignedTransaction alloc] init];
            signedTran.operations = @[content];
            // 7. Transfer
            [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
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
            operation.otcaccount = [ChainObjectId generateFromObject:@"1.2.35"];
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
                                           };
                !successBlock?:successBlock(callback);
            } Error:errorBlock];
        } Error:errorBlock];
    } Error:errorBlock];
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
           IsEncryptionMemo:(BOOL)encryption
                       memo:(NSString *)memo
                    Success:(SuccessBlock)successBlock
                      Error:(Error)errorBlock
{
    
    // 1. Query Transfer object information
    [self getTransferObjFromAccount:fromName toAccount:toName activePrivate:private transferAsset:transferAsset memo:memo Success:^(NSDictionary *operationObj) {
        ChainAccountModel *fromModel = operationObj[@"fromModel"];
        ChainAccountModel *toModel = operationObj[@"toModel"];
        ChainAssetObject *assetModel = operationObj[@"assetModel"];
        ChainEncryptionMemo *memoData = operationObj[@"memoData"];
        
        // 2. Stitching transfer data
        CocosTransferOperation *operation = [[CocosTransferOperation alloc] init];
        operation.from = fromModel.identifier;
        operation.to = toModel.identifier;
        operation.amount = [assetModel getAmountFromNormalFloatString:[NSString stringWithFormat:@"%@",assetAmount]];
        operation.requiredAuthority = fromModel.active.publicKeys;
        if (encryption) {
            if (memoData) {
                operation.memo = @[@(1),memoData];
            }
        }else{
            if (memo.length > 0) {
                operation.memo = @[@(0),memo];
            }
        }
        
        CocosOperationContent *content = [[CocosOperationContent alloc] initWithOperation:operation];
        SignedTransaction *signedTran = [[SignedTransaction alloc] init];
        signedTran.operations = @[content];
        // 3. Transfer
        [self signedTransaction:signedTran activePrivate:private Success:successBlock Error:errorBlock];
    } Error:errorBlock];
}

/** Request object for operation */
- (void)getOperationFromAccount:(NSString *)fromName
                      toAccount:(NSString *)toName
                        Success:(SuccessBlock)successBlock
                          Error:(Error)errorBlock
{
    [self Cocos_GetAccount:fromName Success:^(id fromAccount) {
        ChainAccountModel *fromModel =[ChainAccountModel generateFromObject:fromAccount];
        // 2. Inquiry for payee information
        [self Cocos_GetAccount:toName Success:^(id toAccount) {
            ChainAccountModel *toModel =[ChainAccountModel generateFromObject:toAccount];
            // 3. Return the desired object
            NSMutableDictionary *operationObj = [NSMutableDictionary dictionary];
            operationObj[@"fromModel"] = fromModel;
            operationObj[@"toModel"] = toModel;
            !successBlock?:successBlock(operationObj);
        } Error:errorBlock];
    } Error:errorBlock];
}

/** Request object for transfer */
- (void)getTransferObjFromAccount:(NSString *)fromName
                        toAccount:(NSString *)toName
                    activePrivate:(CocosPrivateKey *)private
                    transferAsset:(NSString *)transferAsset
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
                ChainEncryptionMemo *memoData = nil;
                if (memo.length > 0) {
                    memoData = [[ChainEncryptionMemo alloc] initWithPrivateKey:private anotherPublickKey:toModel.options.memo_key customerNonce:nil totalMessage:memo];
                }
                // 4. Return the desired object
                NSMutableDictionary *operationObj = [NSMutableDictionary dictionary];
                operationObj[@"fromModel"] = fromModel;
                operationObj[@"toModel"] = toModel;
                operationObj[@"assetModel"] = assetModel;
                operationObj[@"memoData"] = memoData;
                !successBlock?:successBlock(operationObj);
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
