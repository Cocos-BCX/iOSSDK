//
//  CocosHTTPManager+CreateAccount.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosHTTPManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CocosHTTPManager (CreateAccount)
/**
 CreateAccount
 
 @param name AccountName
 @param owner_key owner_key
 @param memo_key memo_key
 @param active_key active_key
 */
- (void)Cocos_CreateAccountWithName:(NSString *)name
                          owner_key:(NSString *)owner_key
                           memo_key:(NSString *)memo_key
                         active_key:(NSString *)active_key
                            Success:(SuccessBlock)successBlock
                              Error:(Error)errorBlock;
@end

NS_ASSUME_NONNULL_END
