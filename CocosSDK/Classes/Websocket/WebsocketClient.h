//
//  WebsocketClient.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "CocosSDKError.h"
#import "WebsocketBlockChainApi.h"
#import "UploadBaseModel.h"
@class CallBackModel;
@class UploadParams;

@interface WebsocketClient : NSObject

/**
 ConnectStatus
 Block Chain Connection Status: Marks the Connection Status with Block Chain
 KVO Monitor
 */
@property (nonatomic, assign, readonly) WebsocketConnectStatus connectStatus;

@property (nonatomic, copy) void (^connectStatusChange)(WebsocketConnectStatus connectStatus);

@property (nonatomic, copy, readonly) NSString *connectedUrl;

- (instancetype)initWithUrl:(NSString *)url closedCallBack:(void (^) (NSError *error))closedCallBack;

- (void)connectWithTimeOut:(NSTimeInterval)timeOut;

- (void)sendWithChainApi:(WebsocketBlockChainApi)chainApi method:(WebsocketBlockChainMethodApi)method params:(UploadParams *)uploadParams callBack:(CallBackModel *)callBack;

@end
