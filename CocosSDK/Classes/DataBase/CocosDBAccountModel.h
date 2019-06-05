//
//  CocosDBAccountModel.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/13.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,CocosWalletMode) {
    CocosWalletModeWallet,       // 钱包模式
    CocosWalletModeAccount       // 账户模式
};

NS_ASSUME_NONNULL_BEGIN

@interface CocosDBAccountModel : NSObject

@property (nonatomic, copy) NSString *chainname;

@property (nonatomic, copy) NSString *chainid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *keystone;

@property (nonatomic, assign) CocosWalletMode walletMode;

@end

NS_ASSUME_NONNULL_END
