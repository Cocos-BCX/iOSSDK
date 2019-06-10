//
//  CCWHTTPManager.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosHTTPManager.h"
#import "CocosSDKError.h"

@interface CocosHTTPManager()

@end

@implementation CocosHTTPManager

/** Network Singleton Method */
static CocosHTTPManager *_shareHTTPManager = nil;

+ (instancetype)CCW_shareHTTPManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareHTTPManager = [[CocosHTTPManager alloc] initWithBaseURL:nil sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _shareHTTPManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _shareHTTPManager.requestSerializer.timeoutInterval = 15;
        _shareHTTPManager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 600)];
        _shareHTTPManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain" ,@"application/json", @"text/json", @"text/javascript",@"text/html",@"application/x-gzip", nil];
        _shareHTTPManager.securityPolicy.allowInvalidCertificates = YES;
        _shareHTTPManager.securityPolicy.validatesDomainName = NO;
    });
    return _shareHTTPManager;
}

#pragma mark - base class
/** post request */
- (void)CCW_POST:(NSString *)url Param:(NSMutableDictionary *)parameters Success:(SuccessBlock)successBlock Error:(Error)errorBlock
{
    [self.requestSerializer setValue:@"YnVmZW5nQDIwMThidWZlbmc=" forHTTPHeaderField:@"Authorization"];
    [self POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] integerValue] == SDKErrorCodeCreateAccountExists) {
            NSError *error = [NSError errorWithDomain:@"Account exists" code:SDKErrorCodeCreateAccountExists userInfo:responseObject];
            !errorBlock ?:errorBlock(error);
        }else{
            !successBlock?:successBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !errorBlock ?:errorBlock(error);
    }];
}
@end
