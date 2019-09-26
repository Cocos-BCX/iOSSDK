//
//  CocosSDKError.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,SDKErrorCode) {
    //连接异常(连接中断或尚未连接)
    SDKErrorCodeErrorNotKnown = 0,
    // RPC connection failed. Please check your network
    SDKErrorCodeNotConnected = 301,
    // Parameter error
    SDKErrorCodeErrorParameterError = 1011,
    // The network is busy, please check your network connection
    SDKErrorCodeNetworkBusy = 102,
    // Please enter the correct account name(/^a-z{4,63}/$)
    SDKErrorCodeAccountNameError = 103,
    // XX not found
    SDKErrorCodeAccountNotFound = 104,
    // wrong password,Please enter the correct original/temporary password
    SDKErrorCodePasswordwrong = 105,
    // Please import the private key
    SDKErrorCodePrivateisNull = 107,
    // User name or password error (please confirm that your account is registered in account mode, and the account registered in wallet mode cannot be logged in using account mode)
    SDKErrorCodeAccountNameOrPasswordError = 108,
    // Please enter the correct private key
    SDKErrorCodePrivateError = 109,
    // The private key has no account information
    SDKErrorCodePrivateNoAccount = 110,
    // Please login first
    SDKErrorCodePrivateNotLogin = 111,
    // Must have owner permission to change the password, please confirm that you imported the ownerPrivateKey
    SDKErrorCodeChangePasswordError = 112,
    // There is no asset XX on block chain
    SDKErrorCodeNotFoundAsset = 115,
    // Error fetching account record
    SDKErrorCodeAccountRecordError = 120,
    // No reward available
    SDKErrorNoRewardAvailable = 127,
    // Parameter ‘memo’ can not be empty
    SDKErrorCodeAccountMemoNotEmpty = 129,
    // Please check parameter data type
    SDKErrorCodeParameterDataTypeError = 135,
    // Key import error
    SDKErrorCodeKeyImportError = 150,
    // Account exists
    SDKErrorCodeAccountExists = 159,
    SDKErrorCodeCreateAccountExists = 400,
    SDKErrorCodeBroadcastInsufficientBalance = 100000,//余额不足
    SDKErrorCodeBroadcastMissingRequiredActiveAuthority = 3030001,//缺少校验权限
    SDKErrorCodeApiNotFound,
    SDKErrorCodeBroadcastMissingRequiredOwnerAuthority,
    SDKErrorCodeBroadcastMissingRequiredOtherAuthority,
    SDKErrorCodeBroadcastInsufficientFee = 3030007,
    
};
