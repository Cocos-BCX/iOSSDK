//
//  CocosViewController.m
//  CocosSDK
//
//  Created by SYLing on 03/09/2019.
//  Copyright (c) 2019 SYLing. All rights reserved.
//

#import "CocosViewController.h"
#import <CocosSDK/CocosSDK.h>

#import "Cocos_Key_Account.h"

@interface CocosViewController ()
#pragma mark 钱包模式属性
// 创建账户
@property (weak, nonatomic) IBOutlet UITextField *wallet_createTF;
@property (weak, nonatomic) IBOutlet UITextField *wallet_createpwdTF;
@property (weak, nonatomic) IBOutlet UIButton *wallet_createBtn;
// 备份钱包
@property (weak, nonatomic) IBOutlet UITextField *wallet_backupTF;
// 恢复钱包
@property (weak, nonatomic) IBOutlet UITextField *wallet_recoverTF;
@property (weak, nonatomic) IBOutlet UITextField *wallet_recoverPwdTF;

// 导入私钥
@property (weak, nonatomic) IBOutlet UITextField *wallet_importTF;
@property (weak, nonatomic) IBOutlet UITextField *wallet_importpwdTF;
@property (weak, nonatomic) IBOutlet UIButton *wallet_importBtn;
// 删除钱包
@property (weak, nonatomic) IBOutlet UITextField *wallet_deleteTF;

#pragma mark 账户模式属性
// 创建账户
@property (weak, nonatomic) IBOutlet UITextField *account_createTF;
@property (weak, nonatomic) IBOutlet UITextField *account_createpwdTF;
@property (weak, nonatomic) IBOutlet UIButton *account_createBtn;
// 登录
@property (weak, nonatomic) IBOutlet UITextField *account_loginTF;
@property (weak, nonatomic) IBOutlet UITextField *account_loginpwdTF;
@property (weak, nonatomic) IBOutlet UIButton *account_loginBtn;
// 私钥登录
@property (weak, nonatomic) IBOutlet UITextField *account_privateTF;
@property (weak, nonatomic) IBOutlet UITextField *account_privatepwdTF;
@property (weak, nonatomic) IBOutlet UIButton *account_privateBtn;
// 修改密码
@property (weak, nonatomic) IBOutlet UITextField *account_pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *account_newpwdTF;
@property (weak, nonatomic) IBOutlet UIButton *account_pwdBtn;

// 获取当前账户信息
@property (weak, nonatomic) IBOutlet UITextField *getAccountNameTF;
@property (weak, nonatomic) IBOutlet UIButton *account_getBtn;

// 获取账户操作记录
@property (weak, nonatomic) IBOutlet UITextField *account_optionTF;

// 退出登录
@property (weak, nonatomic) IBOutlet UITextField *account_logoutTF;
@property (weak, nonatomic) IBOutlet UIButton *account_logoutBtn;

// 获取私钥
@property (weak, nonatomic) IBOutlet UITextField *get_pri_account;
@property (weak, nonatomic) IBOutlet UITextField *get_pri_password;

#pragma mark 代币操作属性
// 转账
@property (weak, nonatomic) IBOutlet UITextField *transfer_fromTF;
@property (weak, nonatomic) IBOutlet UITextField *transfer_toTF;
@property (weak, nonatomic) IBOutlet UITextField *transfer_countTF;
@property (weak, nonatomic) IBOutlet UITextField *transfer_assetIDTF;
@property (weak, nonatomic) IBOutlet UITextField *transfer_FeeAssetTF;
@property (weak, nonatomic) IBOutlet UITextField *transfer_noteTF;

// 查询账户拥有的所有资产列表
@property (weak, nonatomic) IBOutlet UITextField *get_assetList_account;
@property (weak, nonatomic) IBOutlet UITextField *get_assetList_ID;

#pragma mark NH资产查询属性
// 查询NH资产详细信息
@property (weak, nonatomic) IBOutlet UITextField *get_info_nhId;
// 查询账户下所拥有的NH资产
@property (weak, nonatomic) IBOutlet UITextField *get_nhasset_account;
@property (weak, nonatomic) IBOutlet UITextField *get_nhasset_worldview;
@property (weak, nonatomic) IBOutlet UITextField *get_nhasset_pageSize;
@property (weak, nonatomic) IBOutlet UITextField *get_nhasset_page;
// 查询账户下NH资产售卖单
@property (weak, nonatomic) IBOutlet UITextField *get_nhassetsell_account;
@property (weak, nonatomic) IBOutlet UITextField *get_nhassetsell_pageSize;
@property (weak, nonatomic) IBOutlet UITextField *get_nhassetsell_page;
// 查询(购买)全网NH资产售卖单
@property (weak, nonatomic) IBOutlet UITextField *get_allnhassetsell_id;
@property (weak, nonatomic) IBOutlet UITextField *get_allnhassetsell_worldview;
@property (weak, nonatomic) IBOutlet UITextField *get_allnhassetsell_baseDescribe;
@property (weak, nonatomic) IBOutlet UITextField *get_allnhassetsell_pageSize;
@property (weak, nonatomic) IBOutlet UITextField *get_allnhassetsell_page;
// 查询世界观详细信息
@property (weak, nonatomic) IBOutlet UITextField *get_worldviewinfo_id;
// 查询开发者所创建的NH资产
@property (weak, nonatomic) IBOutlet UITextField *get_nhassetcreat_account;
@property (weak, nonatomic) IBOutlet UITextField *get_nhassetcreat_pageSize;
@property (weak, nonatomic) IBOutlet UITextField *get_nhassetcreat_page;

@end

@implementation CocosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 自定义发送
//        [[CocosSDK shareInstance] Cocos_SendWithChainApi:(WebsocketBlockChainApiHistory) Method:(WebsocketBlockChainMethodApiCall) MethodName:@"get_account_history_operations" Params:@[@"1.2.926",@(1),@"1.11.5357110",@(10),@"1.11.5357110"] Success:^(id responseObject) {
//            NSLog(@"GetAccountHistoryOpreations %@",responseObject);
//        } Error:^(NSError *error) {
//            NSLog(@"GetAccountHistoryOpreations %@",error);
//        }];

        [[CocosSDK shareInstance] Cocos_CallContract:@"contract.dicegame" ContractMethodParam:@[@"52",@"50"] ContractMethod:@"bet" CallerAccount:@"gnkhandsome1" feePayingAsset:@"1.3.0" Password:@"1111qqqq" Success:^(id responseObject) {
            NSLog(@"Cocos_CallContract \n%@",responseObject);
            
        } Error:^(NSError *error) {
            NSLog(@"Cocos_CallContract erroe  \n%@",error);
        }];
    });

}

#pragma mark - 钱包模式
// 创建钱包
- (IBAction)wallet_createClick:(id)sender
{
//    /^[a-z][a-z0-9\.-]{4,63}$//
    NSString *name = _wallet_createTF.text;
    // 密码是用来保存私钥，临时密码
    NSString *passwd = _wallet_createpwdTF.text;
    
    [[CocosSDK shareInstance] Cocos_CreateAccountWalletMode:CocosWalletModeWallet AccountName:name Password:passwd AutoLogin:YES Success:^(id responseObject) {
        NSLog(@"wallet_createClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"wallet_createClick error :%@",error);
    }];
}

// 备份钱包
- (IBAction)wallet_backupWalletClick:(id)sender
{
    NSString *name = _wallet_backupTF.text;
    [[CocosSDK shareInstance] Cocos_BackupWalletWithAccountName:name Success:^(id responseObject) {
        NSLog(@"wallet_backupWalletClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"wallet_backupWalletClick error :%@",error);
    }];
}

// 恢复钱包
- (IBAction)wallet_recoverWalletClick:(id)sender
{
//    NSString *recover = _wallet_recoverTF.text;
//    NSString *recoverPWD = _wallet_recoverTF.text;
    NSString *recover = @"{\"labeled_keys\":[],\"blind_receipts\":[],\"chain_id\":\"53b98adf376459cc29e5672075ed0c0b1672ea7dce42b0b1fe5e021c02bda640\",\"extra_keys\":[[\"1.2.926\",[\"COCOS76g2PGAudrC2JPpoKpVWMgqCoBC1Cp2ZuaF6RwghEHrfxKnrms\",\"COCOS5doctvP5ttXyn6mzxrHgp8fN8f9KL4f2P7FCqVzHtV8PpoFhXC\"]]],\"pending_witness_registrations\":[],\"cipher_keys\":\"83e6f5f78f410f5e847996d55213ee2dcc188be6f85771401ea8e16f1f05e02866c0fdd21f4d766e0122bf754a2c2155d258e98574896eee703a13ffa90a3463bfeb9d08fdd9decb2252f79842eb85f94db307ef469e853233c81e2e72b22cc4830d69932fcd524054563aa55556e330609e3c94808b87d74e786d5e9d2be085a47cd46b1d2f5a51dd41ba2dd92fbc7e85484a63066e2542cfe9e5deaddcd5e475cc3acf83e91c5fdb22216621fdddc5ea8d8c3ce2dbd99ea986cb7599fc0de4324097b8ed975010bd8e364b31bf337db33441c4bfb0ed96d38d8827bbdf7d7e5ae17261c0d402f305ed9f3e611a606a\",\"pending_account_registrations\":[],\"ws_server\":\"ws://47.93.62.96:8050\",\"my_accounts\":[{\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"COCOS76g2PGAudrC2JPpoKpVWMgqCoBC1Cp2ZuaF6RwghEHrfxKnrms\",1]],\"address_auths\":[]},\"lifetime_referrer\":\"1.2.17\",\"options\":{\"memo_key\":\"COCOS76g2PGAudrC2JPpoKpVWMgqCoBC1Cp2ZuaF6RwghEHrfxKnrms\",\"extensions\":[],\"num_witness\":0,\"voting_account\":\"1.2.5\",\"num_committee\":0,\"votes\":[]},\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"COCOS5doctvP5ttXyn6mzxrHgp8fN8f9KL4f2P7FCqVzHtV8PpoFhXC\",1]],\"address_auths\":[]},\"referrer_rewards_percentage\":0,\"network_fee_percentage\":2000,\"whitelisted_accounts\":[],\"name\":\"testtest2\",\"membership_expiration_date\":\"1970-01-01T00:00:00\",\"registrar\":\"1.2.17\",\"referrer\":\"1.2.17\",\"id\":\"1.2.926\",\"blacklisted_accounts\":[],\"whitelisting_accounts\":[],\"statistics\":\"2.6.926\",\"owner_special_authority\":[0,{}],\"blacklisting_accounts\":[],\"top_n_control_flags\":0,\"active_special_authority\":[0,{}],\"lifetime_referrer_fee_percentage\":3000}]}";
    NSString *recoverPWD = @"123456";
    [[CocosSDK shareInstance] Cocos_RecoverWalletWithString:recover KeystonePwd:recoverPWD Success:^(id responseObject) {
        NSLog(@"wallet_recoverWalletClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"wallet_recoverWalletClick error :%@",error);
    }];
}

// 导入私钥
- (IBAction)wallet_importClick:(id)sender
{
    NSString *importPri = _wallet_importTF.text;
    NSString *importPriPwd = _wallet_importpwdTF.text;
    //    5KfSabfGfm2nagRUrZqEpc1CFueYod2sFLVvGX1ygbJ23SCK4pd
    //    5KL7ZrUzAgZbPFjvvmUqETHvLe2xWS926CstCtD8ijinSu4vXtv
    importPri = @"5KL7ZrUzAgZbPFjvvmUqETHvLe2xWS926CstCtD8ijinSu4vXtv";
    importPriPwd = @"111111";
    [[CocosSDK shareInstance] Cocos_ImportWalletWithPrivate:importPri WalletMode:CocosWalletModeWallet TempPassword:importPriPwd Success:^(id responseObject) {
        NSLog(@"wallet_importClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"wallet_importClick error :%@",error);
    }];
}
// 删除钱包
- (IBAction)wallet_deleteWalletClick:(id)sender
{
    NSString *name = _wallet_deleteTF.text;
    [[CocosSDK shareInstance] Cocos_DeleteWalletAccountName:name Success:^(id responseObject) {
        NSLog(@"wallet_deleteWalletClick Success:\n%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"wallet_deleteWalletClick error :%@",error);
    }];
}

// 获取钱包账户列表
- (IBAction)wallet_getAccountClick:(id)sender
{
    [[CocosSDK shareInstance] Cocos_QueryAllAccountSuccess:^(id responseObject) {
        NSLog(@"wallet_getAccountClick Success:\n%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"wallet_getAccountClick error :%@",error);
    }];
}

#pragma mark - 账户模式
- (IBAction)account_createClick:(id)sender
{
    NSString *name = _account_createTF.text;
    NSString *passwd = _account_createpwdTF.text;
    
    [[CocosSDK shareInstance] Cocos_CreateAccountWalletMode:CocosWalletModeAccount AccountName:name Password:passwd AutoLogin:YES Success:^(id responseObject) {
        NSLog(@"account_createClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"account_createClick error :%@",error);
    }];
}

// 登录
- (IBAction)account_loginClick:(id)sender
{
    NSString *name = _account_loginTF.text;
    NSString *passwd = _account_loginpwdTF.text;
    
    [[CocosSDK shareInstance] Cocos_LoginAccountWithName:name Password:passwd Success:^(id responseObject) {
        NSLog(@"account_loginClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"account_loginClick error :%@",error);
    }];
}

// 私钥登录
- (IBAction)account_privateClick:(id)sender
{
    NSString *importPri = _account_privateTF.text;
    NSString *importPriPwd = _account_privatepwdTF.text;
    [[CocosSDK shareInstance] Cocos_ImportWalletWithPrivate:importPri WalletMode:CocosWalletModeAccount TempPassword:importPriPwd Success:^(id responseObject) {
        NSLog(@"account_privateClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"account_privateClick error :%@",error);
    }];
}

// 修改密码
- (IBAction)account_pwdClick:(id)sender
{
    
}

// 获取当前账户
- (IBAction)account_getClick:(id)sender
{
    NSString *accountName = _getAccountNameTF.text;
    [[CocosSDK shareInstance] Cocos_GetAccount:accountName Success:^(id responseObject) {
        NSLog(@"account_getClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"account_getClick error :%@",error);
    }];
}

// 账户操作记录
- (IBAction)account_option_historyClick:(id)sender {
    NSString *accountName = _account_optionTF.text;
    [[CocosSDK shareInstance] Cocos_GetAccountHistory:accountName Limit:10 Success:^(NSArray *responseObject) {
        NSLog(@"account_option_historyClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"account_option_historyClick error :%@",error);
    }];
}

// 退出登录
- (IBAction)account_logoutClick:(id)sender
{
    NSString *name = _account_logoutTF.text;
    [[CocosSDK shareInstance] Cocos_DeleteWalletAccountName:name Success:^(id responseObject) {
        NSLog(@"account_logoutClick Success:\n%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"account_logoutClick error :%@",error);
    }];

}

// 获取私钥
- (IBAction)getPrivi:(id)sender
{
    NSString *name = _get_pri_account.text;
    NSString *password = _get_pri_password.text;
    [[CocosSDK shareInstance] Cocos_GetPrivateWithName:name Password:password Success:^(id responseObject) {
        NSLog(@"account_logoutClick Success:\n%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"account_logoutClick error :%@",error);
    }];
}
#pragma mark - 代币到账
// 获取手续费
- (IBAction)getTransferClick:(UIButton *)sender {
    [[CocosSDK shareInstance] Cocos_GetTransferFeesFrom:@"gnkhandsome2" ToAccount:@"testtest2" Password:@"123456" TransferAsset:@"COCOS" AssetAmount:@"0.1" FeePayingAsset:@"COCOS" Memo:@"gnk high big" Success:^(id responseObject) {
        NSLog(@"Cocos_GetTransferFeesFrom 1 success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Cocos_GetTransferFeesFrom 1 error :%@",error);
    }];
}

// 转账
- (IBAction)transferClick:(id)sender {
    
    [[CocosSDK shareInstance] Cocos_TransferFromAccount:@"syling" ToAccount:@"gnkhandsome1" Password:@"1111aaaa" TransferAsset:@"COCOS" AssetAmount:@"10" FeePayingAsset:@"COCOS" Memo:@"" Success:^(id responseObject) {
        NSLog(@"transferClick success :%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"transferClick error :%@",error);
    }];
}

// 查询账户拥有的所有资产列表
- (IBAction)GetAccountBalance:(id)sender
{
    // 查询账户拥有的所有资产列表
    [[CocosSDK shareInstance] Cocos_GetAccountBalance:@"1.2.62" CoinID:@[] Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];

}

// 查询链上资产
- (IBAction)Cocos_ChainAssetList:(id)sender
{
    // 查询链上资产
    [[CocosSDK shareInstance] Cocos_ChainListLimit:100 Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];
}

#pragma mark - NH资产查询
// 查询NH资产详细信息
- (IBAction)NHAssetInfo:(id)sender
{
    NSString *nhId = _get_info_nhId.text;
    [[CocosSDK shareInstance] Cocos_LookupNHAsset:@[nhId] Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];
}
// 查询账户下所拥有的NH资产
- (IBAction)getAllNHAssetOfAccount:(id)sender
{
    [[CocosSDK shareInstance] Cocos_ListAccountNHAsset:@"1.2.73" WorldView:@[@"4.1.5"] PageSize:100 Page:1 Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];
}

// 查询账户下的NH资产售卖单
- (IBAction)getSellListNHAssetOfAccount:(id)sender
{
    [[CocosSDK shareInstance] Cocos_ListAccountNHAssetOrder:@"1.2.136" PageSize:10 Page:1 Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];
}

// 查询(购买)全网NH资产售卖单
- (IBAction)getAllSellListNHAsset:(id)sender
{
    [[CocosSDK shareInstance] Cocos_AllListNHAssetOrder:@"" WorldView:@"" BaseDescribe:@"" PageSize:10 Page:1 Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];
}
// 查询世界观详细信息
- (IBAction)getWorldViewInfo:(id)sender
{
    [[CocosSDK shareInstance] Cocos_LookupWorldView:@[@"SYLing"] Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];
}

// 查询开发者所创建的NH资产
- (IBAction)getNHAssetsForDeveloper:(id)sender
{
    [[CocosSDK shareInstance] Cocos_ListNHAssetByCreator:@"1.2.62" PageSize:10 Page:1 Success:^(id responseObject) {
        NSLog(@"Success:%@",responseObject);
    } Error:^(NSError *error) {
        NSLog(@"Error:%@",error);
    }];
}

#pragma mark - NH资产操作

@end
