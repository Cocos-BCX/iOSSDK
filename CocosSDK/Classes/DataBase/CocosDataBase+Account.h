//
//  CocosDataBase+Account.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/12.
//
//  存储最基本的用户信息，用户名和id 等

#import "CocosDataBase.h"
#import "CocosDBAccountModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CocosDataBase (Account)
/* Create user account table */
- (void)Cocos_CreateAccountTable;

/* Save user accounts */
- (void)Cocos_SaveAccountModel:(CocosDBAccountModel *)account;

/** Query all user accounts by chainId */
- (NSMutableArray<CocosDBAccountModel *> *)Cocos_QueryMyAllAccountWithChainId:(NSString *)chainId;

/** Query all user accounts name */
- (NSMutableArray<CocosDBAccountModel *> *)Cocos_QueryMyAllAccountNameWithChainId:(NSString *)chainId;

/** Query all user accounts Id */
- (NSMutableArray<CocosDBAccountModel *> *)Cocos_QueryMyAllAccountIdWithChainId:(NSString *)chainId;

/** Query Users with Account Names */
- (CocosDBAccountModel *)Cocos_QueryMyAccountWithName:(NSString *)name addChainId:(NSString *)chainId;

/** Use username to query account login mode */
- (CocosWalletMode)Cocos_QueryAccountTypeWithName:(NSString *)name addChainId:(NSString *)chainId;

/** Query Users with User ID */
- (CocosDBAccountModel *)Cocos_QueryMyAccountWithUserID:(NSString *)userID addChainId:(NSString *)chainId;

/* Delete a user from the user table */
- (void)Cocos_DeleteAccountWithName:(NSString *)name addChainId:(NSString *)chainId;

@end

NS_ASSUME_NONNULL_END
