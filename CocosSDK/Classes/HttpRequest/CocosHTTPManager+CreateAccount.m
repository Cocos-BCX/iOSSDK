//
//  CocosHTTPManager+CreateAccount.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosHTTPManager+CreateAccount.h"
#import "CocosConfig.h"
#import "CocosConstkey.h"

@implementation CocosHTTPManager (CreateAccount)

/** CreateAccount */
- (void)Cocos_CreateAccountWithName:(NSString *)name
                          owner_key:(NSString *)owner_key
                           memo_key:(NSString *)memo_key
                         active_key:(NSString *)active_key
                            Success:(SuccessBlock)successBlock
                              Error:(Error)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[CocosConfig faucetUrl],kCocosCreateAccount];
    NSMutableDictionary *paramAccount = [NSMutableDictionary dictionary];
    paramAccount[@"name"] = name;
    paramAccount[@"owner_key"] = owner_key;
    paramAccount[@"memo_key"] = memo_key;
    paramAccount[@"active_key"] = active_key;
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:paramAccount forKey:@"account"];
    [[CocosHTTPManager CCW_shareHTTPManager] CCW_POST:url Param:param Success:successBlock Error:errorBlock];
}
@end
