//
//  UploadBaseModel.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
@class UploadParams;

typedef NS_ENUM(NSInteger,WebsocketBlockChainMethodApi) {
    WebsocketBlockChainMethodApiCall,//
    WebsocketBlockChainMethodApiNotice,//
};

@interface UploadBaseModel : NSObject

@property (nonatomic, assign) WebsocketBlockChainMethodApi method;

@property (nonatomic, assign) NSInteger identifier;

@property (nonatomic, strong) UploadParams *params;

- (NSDictionary *)convertData;

@end
