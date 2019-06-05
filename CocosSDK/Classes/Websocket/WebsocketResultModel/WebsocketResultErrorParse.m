//
//  WebsocketResultErrorParse.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "WebsocketResultErrorParse.h"
#import "CocosSDkError.h"

@implementation WebsocketResultErrorParse

+ (NSError *)generateFromError:(NSDictionary *)errorDic {
    NSDictionary *data = errorDic[@"data"];
    
    SDKErrorCode code = [data[@"code"] integerValue];
    
    NSString *message = errorDic[@"message"];
    
    switch (code) {
            
            
        case SDKErrorCodeBroadcastInsufficientFee:{
            return [NSError errorWithDomain:message code:code userInfo:@{@"data":data[@"stack"][0][@"data"],@"chineseMessage":[NSString stringWithFormat:@"账户给定付出手续费不足,请给付足额手续费"]}];
        }
            break;
        case SDKErrorCodeBroadcastMissingRequiredActiveAuthority:
            return [NSError errorWithDomain:message code:code userInfo:@{@"data":data[@"stack"][0][@"data"],@"chineseMessage":[NSString stringWithFormat:@"缺少账户活动私钥"]}];
            break;
        case SDKErrorCodeBroadcastMissingRequiredOwnerAuthority:
            return [NSError errorWithDomain:message code:code userInfo:@{@"data":data[@"stack"][0][@"data"],@"chineseMessage":[NSString stringWithFormat:@"缺少账户所有者私钥"]}];
            break;
        case SDKErrorCodeBroadcastMissingRequiredOtherAuthority:
            return [NSError errorWithDomain:message code:code userInfo:@{@"data":data[@"stack"][0][@"data"],@"chineseMessage":[NSString stringWithFormat:@"缺少账户其他权限私钥"]}];
            break;
        case 10:{
            if ([message containsString:@"Insufficient Balance"]) {
                return [NSError errorWithDomain:message code:SDKErrorCodeBroadcastInsufficientBalance userInfo:nil];
            }
        }
            break;
        default:
            break;
            
    }
    
    return [NSError errorWithDomain:@"failed" code:SDKErrorCodeErrorNotKnown userInfo:errorDic];
}

@end
