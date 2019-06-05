//
//  KeystoneFile.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
#import "ChainAccountModel.h"
#import "WalletExtraKey.h"
#import "PlainKey.h"

@class CocosPrivateKey,CocosPublicKey;

@interface KeystoneFile : NSObject<ObjectToDataProtocol>

@property (nonatomic, copy) NSString *chain_id;

@property (nonatomic, copy) NSArray <ChainAccountModel *>*my_accounts;

@property (nonatomic, strong) PlainKey *cipher_keys;

@property (nonatomic, copy) NSArray <WalletExtraKey *>*extra_keys;
@property (nonatomic, copy) NSString *ws_server;

//@property (nonatomic, copy) NSArray *pending_account_registrations;
//@property (nonatomic, copy) NSArray *pending_witness_registrations;
//@property (nonatomic, copy) NSArray *labeled_keys;
//@property (nonatomic, copy) NSArray *blind_receipts;
//@property (nonatomic, copy) NSString *ws_user;
//@property (nonatomic, copy) NSString *ws_password;
//- (BOOL)isLocked;
//- (BOOL)canSetPassword;
//- (BOOL)unlockWithString:(NSString *)string error:(NSError **)error;
//- (BOOL)lockWithString:(NSString *)string;

- (BOOL)importKey:(CocosPrivateKey *)key
       ForAccount:(ChainAccountModel *)account;

- (BOOL)lockKeyWithString:(NSString *)string;

- (CocosPrivateKey *)getPrivateKeyPwd:(NSString *)pwdString
                        FromPublicKey:(CocosPublicKey *)publicKey;

@end
