//
//  CocosConfig.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>

@interface CocosConfig : NSObject

+ (void)setPrefix:(NSString *)prefix;

+ (NSString *)prefix;

+ (void)setChainId:(NSString *)chainId;

+ (NSString *)chainId;

+ (void)setFaucetUrl:(NSString *)faucetUrl;

+ (NSString *)faucetUrl;
@end
