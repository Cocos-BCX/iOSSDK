//
//  CocosConfig.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosConfig.h"

@interface CocosConfig ()

@property (nonatomic, copy) NSString *prefix;

@property (nonatomic, copy) NSString *chainId;

@property (nonatomic, copy) NSString *faucetUrl;

@end

@implementation CocosConfig

+ (instancetype)shareInstance {
    static CocosConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CocosConfig alloc] init];
    });
    
    return sharedInstance;
}

+ (void)setPrefix:(NSString *)prefix {
    [CocosConfig shareInstance].prefix = prefix;
}

+ (NSString *)prefix {
    return [CocosConfig shareInstance].prefix;
}

+ (void)setChainId:(NSString *)chainId {
    [CocosConfig shareInstance].chainId = chainId;
}

+ (NSString *)chainId {
    return [CocosConfig shareInstance].chainId;
}

+ (void)setFaucetUrl:(NSString *)faucetUrl {
    [CocosConfig shareInstance].faucetUrl = faucetUrl;
}

+ (NSString *)faucetUrl {
    return [CocosConfig shareInstance].faucetUrl;
}



@end
