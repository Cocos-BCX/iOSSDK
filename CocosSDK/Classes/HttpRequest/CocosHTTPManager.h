//
//  CocosHTTPManager.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^SuccessBlock)(id responseObject);// success callback
typedef void (^Error)(NSError *error);// error callback


@interface CocosHTTPManager : AFHTTPSessionManager

/** Network Singleton Method */
+ (instancetype)CCW_shareHTTPManager;

/** post request */
- (void)CCW_POST:(NSString *)url Param:(NSMutableDictionary * _Nonnull )parameters Success:(SuccessBlock)successBlock Error:(Error)errorBlock;

@end
