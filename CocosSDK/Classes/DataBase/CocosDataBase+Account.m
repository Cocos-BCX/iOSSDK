//
//  CocosDataBase+Account.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/12.
//

#import "CocosDataBase+Account.h"
#import "ChainAccountModel.h"

@implementation CocosDataBase (Account)
/* Create user account table */
- (void)Cocos_CreateAccountTable
{
    // Create(field：name, id, keystone、Wallet mode)
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_sdk_account (chainname text PRIMARY KEY, name text ,chainid text , id text, keystone text, walletMode integer);"];
        // Add database table columns
//        if (![db columnExists:@"walletMode" inTableWithName:@"t_sdk_account"]){
//            NSString *addIDSql = [NSString stringWithFormat:@"ALTER TABLE t_sdk_account ADD COLUMN ID text;"];
//            [db executeUpdate:addIDSql];
//        }
    }];
}

/* Save user accounts */
- (void)Cocos_SaveAccountModel:(CocosDBAccountModel *)account
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT OR REPLACE INTO t_sdk_account(chainname, chainid, name, id, keystone, walletMode) VALUES (? ,? ,? ,? ,? ,?);",account.chainname,account.chainid,account.name, account.ID,account.keystone,@(account.walletMode)];
    }];
}

/** Query all user accounts  */
- (NSMutableArray<CocosDBAccountModel *> *)Cocos_QueryMyAllAccountWithChainId:(NSString *)chainId
{
    NSMutableArray *myAccountArray = [NSMutableArray array];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_sdk_account where chainid = %@;",chainId];
        while (resultSet.next) {
            CocosDBAccountModel *WalletModel = [[CocosDBAccountModel alloc] init];
            WalletModel.chainname = [resultSet stringForColumn:@"chainname"];
            WalletModel.chainid = [resultSet stringForColumn:@"chainid"];
            WalletModel.name = [resultSet stringForColumn:@"name"];
            WalletModel.ID = [resultSet stringForColumn:@"id"];
            WalletModel.keystone = [resultSet stringForColumn:@"keystone"];
            WalletModel.walletMode = [resultSet intForColumn:@"walletMode"];
            [myAccountArray addObject:WalletModel];
        }
        [resultSet close];
    }];
    return myAccountArray;

}

/** Query all user accounts name */
- (NSMutableArray<CocosDBAccountModel *> *)Cocos_QueryMyAllAccountNameWithChainId:(NSString *)chainId
{
    NSMutableArray *allAccountNameArray = [NSMutableArray array];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_sdk_account where chainid = %@;",chainId];
        while (resultSet.next) {
            [allAccountNameArray addObject:[resultSet stringForColumn:@"name"]];
        }
        [resultSet close];
    }];
    return allAccountNameArray;
}

/** Query all user accounts Id */
- (NSMutableArray<CocosDBAccountModel *> *)Cocos_QueryMyAllAccountIdWithChainId:(NSString *)chainId
{
    NSMutableArray *allAccountNameArray = [NSMutableArray array];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_sdk_account where chainid = %@;",chainId];
        while (resultSet.next) {
            [allAccountNameArray addObject:[resultSet stringForColumn:@"id"]];
        }
        [resultSet close];
    }];
    return allAccountNameArray;
    
}

/** Query Users with Account Names */
- (CocosDBAccountModel *)Cocos_QueryMyAccountWithName:(NSString *)name addChainId:(NSString *)chainId
{
    __block CocosDBAccountModel *WalletModel = [[CocosDBAccountModel alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_sdk_account where name = %@ and chainid = %@;",name,chainId];
        while (resultSet.next) {
            WalletModel.chainname = [resultSet stringForColumn:@"chainname"];
            WalletModel.chainid = [resultSet stringForColumn:@"chainid"];
            WalletModel.name = [resultSet stringForColumn:@"name"];
            WalletModel.ID = [resultSet stringForColumn:@"id"];
            WalletModel.keystone = [resultSet stringForColumn:@"keystone"];
            WalletModel.walletMode = [resultSet intForColumn:@"walletMode"];
        }
        [resultSet close];
    }];
    return WalletModel;
}

/** Use username to query account login mode */
- (CocosWalletMode)Cocos_QueryAccountTypeWithName:(NSString *)name addChainId:(NSString *)chainId
{
    __block CocosWalletMode WalletMode;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_sdk_account where name = %@ and chainid = %@;",name,chainId];
        while (resultSet.next) {
            WalletMode = [resultSet intForColumn:@"walletMode"];
        }
        [resultSet close];
    }];
    return WalletMode;
}

/** Query Users with User ID */
- (CocosDBAccountModel *)Cocos_QueryMyAccountWithUserID:(NSString *)userID addChainId:(NSString *)chainId
{
    __block CocosDBAccountModel *WalletModel = [[CocosDBAccountModel alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_sdk_account where id = %@ and chainid = %@;",userID,chainId];
        while (resultSet.next) {
            WalletModel.chainname = [resultSet stringForColumn:@"chainname"];
            WalletModel.chainid = [resultSet stringForColumn:@"chainid"];
            WalletModel.name = [resultSet stringForColumn:@"name"];
            WalletModel.ID = [resultSet stringForColumn:@"id"];
            WalletModel.keystone = [resultSet stringForColumn:@"keystone"];
            WalletModel.walletMode = [resultSet intForColumn:@"walletMode"];
        }
        [resultSet close];
    }];
    return WalletModel;

}

/* Delete a user from the account table */
- (void)Cocos_DeleteAccountWithName:(NSString *)name addChainId:(NSString *)chainId
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdateWithFormat:@"DELETE FROM t_sdk_account WHERE name = %@ and chainId = %@;",name,chainId];
    }];
}

@end
