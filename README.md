[中文](https://github.com/Cocos-BCX/iOSSDK/blob/master/README_cn.md "中文")

# CocosSDK integration documentation

[![CI Status](https://img.shields.io/travis/SYLing/CocosSDK.svg?style=flat)](https://travis-ci.org/SYLing/CocosSDK)
[![Version](https://img.shields.io/cocoapods/v/CocosSDK.svg?style=flat)](https://cocoapods.org/pods/CocosSDK)
[![License](https://img.shields.io/cocoapods/l/CocosSDK.svg?style=flat)](https://cocoapods.org/pods/CocosSDK)
[![Platform](https://img.shields.io/cocoapods/p/CocosSDK.svg?style=flat)](https://cocoapods.org/pods/CocosSDK)

## Example

- To run the sample project, the repo shall be cloned and then run the 'pod install' from the sample directory. (if you don’t have CocoaPods installed, install it first)
- Modify the configuration of Secp256k1_A as shown in the figure:
	![](xcode_secp_target_setting.png)

## Dependent Libraries

- Dependent Libraries
	- AFNetworking
	- FMDB
	- Secp256k1_A
	- SocketRocket

## Installation

1. Integrated installation using CocoaPods(To be supported)

	```ruby
	pod 'CocosSDK'
	```

2. Manual integration
	- Add all the files in the Class folder under the CocosSDK directory.
	- Add dependent libraries to the project.

## Basic Functions

#### Initialization

1. User guide
	- Initialize SDK, connect nodes, configure ChainId and chain identifier

2. Interface function

	```ruby
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
	    ConnectedStatus:(void (^)(WebsocketConnectStatus 	connectStatus))connectedStatus;
    ```

3. Example code

	```ruby
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Test node
    [[CocosSDK shareInstance] Cocos_ConnectWithNodeUrl:@"ws://39.106.126.54:8050" Fauceturl:@"http://47.93.62.96:3000" TimeOut:2 CoreAsset:@"COCOS" ChainId:@"53b98adf376459cc29e5672075ed0c0b1672ea7dce42b0b1fe5e021c02bda640" ConnectedStatus:^(WebsocketConnectStatus connectStatus) {
    }];
    return YES;
}
	```

#### Set log output

1. User guide
	- Set whether to output the log information of sdk in the console

2. Interface function

    ```ruby
	/**
	 *  Open debug log
	 *
	 *  @param isOpen YES means open，No means close
	 */
	- (void)Cocos_OpenLog:(BOOL)isOpen;
    ```


## Interface function

1. User guide

#### Wallet mode
- Create an account in wallet mode. Accounts created in wallet mode cannot be logged in with account name and password.

#### Account mode
- Create an account in account mode. Accounts created in wallet mode can be logged in with an account name and password.

2. Interface function

	```ruby
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

	```

#### Delete/logout wallet

1. User guide
	- Delete the login and import records saved by the SDK

2. Interface function

    ```ruby

    /**
     Delete wallet
     @param accountName Account
     */
    - (void)Cocos_DeleteWalletAccountName:(NSString *)accountName
              Success:(SuccessBlock)successBlock
                Error:(Error)errorBlock;
	```

#### Login wallet

1. User guide
	- Log in to the wallet with the account name and password

2. Interface function

    ```ruby
    /**
     Log in by account

     @param accountName Account
     @param password    Password
     */
    - (void)Cocos_LoginAccountWithName:(NSString *)accountName
              Password:(NSString *)password
                Success:(SuccessBlock)successBlock
                  Error:(Error)errorBlock;
    ```

#### Transfer

1. User guide
	- Transfer

2. Interface function
    ```ruby
    /**
     Transfer

     @param fromName        Sender's account
     @param toName          Receiver's account
     @param password        Password
     @param transferAsset   Asset's name(eg. COCOS)
     @param assetAmount     assetAmount Transfer amount
     @param feePayingAsset  Charge's currency(require)
     @param memo            Memo String
     */
    - (void)Cocos_TransferFromAccount:(NSString *)fromName
                  ToAccount:(NSString *)toName
                   Password:(NSString *)password
              TransferAsset:(NSString *)transferAsset
                AssetAmount:(NSString *)assetAmount
             FeePayingAsset:(NSString *)feePayingAsset
                       Memo:(NSString *)memo
                  Success:(SuccessBlock)successBlock
                    Error:(Error)errorBlock;
    ```

##	Status Code
## Description

| code | message | Description |
| --- | --- | --- |
| 300 | Chain sync error, please check your system clock | Chain sync error, please check your system clock |
| 301 | RPC connection failed. Please check your network | RPC connection failed. Please check your network |
| 1 | None | Operation succeeded |
| 0 | failed | The operation failed, and the error status description is not fixed. You can directly prompt res.message or to prompt the operation failure. |
| 101 | Parameter is missing | Parameter is missing |
| 1011 | Parameter error | Parameter error | 
| 102 | The network is busy, please check your network connection | The network is busy, please check your network connection |
| 103 | Please enter the correct account name(/^[a-z]([a-z0-9\.-]){4,63}/$) | Please enter the correct account name(/^a-z{4,63}/$) |
| 104 | XX not found | XX not found |
| 105 | wrong password | wrong password |
| 106 | The account is already unlocked | The account is already unlocked |
| 107 | Please import the private key | Please import the private key |
| 108 | User name or password error (please confirm that your account is registered in account mode, and the account registered in wallet mode cannot be logged in using account mode) | User name or password error (please confirm that your account is registered in account mode, and the account registered in wallet mode cannot be logged in using account mode) |
| 109 | Please enter the correct private key | Please enter the correct private key |
| 110 | The private key has no account information | The private key has no account information |
| 111 | Please login first | Please login first |
| 112 | Must have owner permission to change the password, please confirm that you imported the ownerPrivateKey | Must have owner permission to change the password, please confirm that you imported the ownerPrivateKey |
| 113 | Please enter the correct original/temporary password | Please enter the correct original/temporary password |
| 114 | Account is locked or not logged in. | Account is locked or not logged in | 
| 115 | There is no asset XX on block chain | There is no asset XX on block chain | 
| 116 | Account receivable does not exist | Account receivable does not exist |
| 117 | The current asset precision is configured as X ,and the decimal cannot exceed X | The current asset precision is configured as X ,and the decimal cannot exceed X |
| 118 | Encrypt memo failed | Encrypt memo failed |
| 119 | Expiry of the transaction | Expiry of the transaction |
| 120 | Error fetching account record | Error fetching account record |
| 121 | block and transaction information cannot be found | block and transaction information cannot be found |
| 122 | Parameter blockOrTXID is incorrect | Parameter blockOrTXID is incorrect |
| 123 | Parameter account can not be empty | Parameter account can not be empty |
| 124 | Receivables account name can not be empty | Receivables account name can not be empty | 
| 125 | Users do not own XX assets | Users do not own XX assets |
| 127 | No reward available | No reward available |
| 129 | Parameter 'memo' can not be empty | Parameter memo can not be empty memo |
| 130 | Please enter the correct contract name(/^[a-z]([a-z0-9\.-]){4,63}$/) | Please enter the correct contract name(/^a-z{4,63}$/) | 
| 131 | Parameter 'worldView' can not be empty | Parameter WorldView can not be empty |
| 133 | Parameter 'toAccount' can not be empty | Parameter toAccount can not be empty toAccount |
| 135 | Please check parameter data type | Please check parameter data type | 
| 136 | Parameter 'orderId' can not be empty | Parameter orderId can not be empty |
| 137 | Parameter 'NHAssetHashOrIds' can not be empty | Parameter 'NHAssetHashOrIds' can not be empty |
| 138 | Parameter 'url' can not be empty | Parameter 'url' can not be empty |
| 139 | Node address must start with ws:// or wss:// | Node address must start with ws:// or wss:// |
| 140 | API server node address already exists | API server node address already exists | 
| 141 | Please check the data in parameter NHAssets |  Please check the data in parameter NHAssets |
| 142 | Please check the data type of parameter NHAssets | Please check the data type of parameter NHAssets |
| 144 | Your current batch creation / deletion / transfer number is X , and batch operations can not exceed X | Your current batch creation / deletion / transfer number is X , and batch operations can not exceed X |
| 145 | XX contract not found | XX contract not found | 
| 146 | The account does not contain information about the contract | The account does not contain information about the contract | 
| 147 | NHAsset do not exist | NHAsset do not exist | 
| 148 | Request timeout, please try to unlock the account or login the account | Request timeout, please try to unlock the account or login the account | 
| 149 | This wallet has already been imported | This wallet has already been imported |
| 150 | Key import error | Key import error |
| 151 | File saving is not supported | File saving is not supported | 
| 152 | Invalid backup to download conversion | Invalid backup to download conversion |
| 153 | Please unlock your wallet first | Please unlock your wallet first |
| 154 | Please restore your wallet first | Please restore your wallet first |
| 155 | Your browser may not support wallet file recovery | Your browser may not support wallet file recovery | 
| 156 | The wallet has been imported. Do not repeat import | The wallet has been imported. Do not repeat import |
| 157 | Can't delete wallet, does not exist in index | Can't delete wallet, does not exist in index |
| 158 | Imported Wallet core assets can not be XX , and it should be XX | Imported Wallet core assets can not be XX , and it should be XX | 
| 159 | Account exists | Account exists | 
| 160 | You are not the creator of the Asset XX | You are not the creator of the Asset XX | 
| 161 | Orders do not exist | Orders do not exist | 
| 162 | The asset already exists | The asset already exists |
| 163 | The wallet already exists. Please try importing the private key | The wallet already exists. Please try importing the private key | 
| 164 | worldViews do not exist | worldViews do not exist | 
| 165 | There is no wallet account information on the chain | There is no wallet account information on the chain | 
| 166 | The Wallet Chain ID does not match the current chain configuration information. The chain ID of the wallet is: XX | The Wallet Chain ID does not match the current chain configuration information. The chain ID of the wallet is: XX |
| 167 | The current contract version ID was not found | The current contract version ID was not found |
| 168 | This subscription does not exist | This subscription does not exist | 
| 169 | Method does not exist | Method does not exist |


## Project

- CocosBCXWallet

## License

CocosSDK is available under the MIT license. See the LICENSE file for more info.
