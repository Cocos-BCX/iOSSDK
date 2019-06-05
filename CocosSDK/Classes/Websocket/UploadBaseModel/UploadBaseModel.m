//
//  UploadBaseModel.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "UploadBaseModel.h"
#import "UploadParams.h"
@implementation UploadBaseModel

- (NSDictionary *)convertData {
    NSString *method = self.method == WebsocketBlockChainMethodApiCall?@"call":@"notice";
    
    return @{@"method":method,@"id":@(self.identifier),@"params":[self.params convertData]};
}

@end
