//
//  WebsocketClient.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "WebsocketClient.h"
#import <SocketRocket/SocketRocket.h>

#import "UploadParams.h"
#import "CallBackModel.h"
#import "WebsocketResultModel.h"

#import "WebsocketResultErrorParse.h"
#import "CocosSetting.h"

@interface WebsocketClient ()<SRWebSocketDelegate>
/**
 Thread safy auto increament integer
 */
@property (nonatomic, assign, readonly) NSInteger currentId;
/**
 lock for currentId safy
 */
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) SRWebSocket *websocket;

@property (nonatomic, copy) void (^closeCallBack) (NSError *error);

@property (nonatomic, assign) NSInteger normalApi;

@property (nonatomic, assign) NSInteger dataBaseApi;

@property (nonatomic, assign) NSInteger networkBroadCastApi;

@property (nonatomic, assign) NSInteger historyApi;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *,CallBackModel *>*callDictionary;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *,CallBackModel *>*noticeDictionary;

@property (nonatomic, strong) NSLock *sendLock;

@end

@implementation WebsocketClient

@synthesize currentId = _currentId;

- (instancetype)initWithUrl:(NSString *)url closedCallBack:(void (^)(NSError *))closedCallBack{
    if (self = [super init]) {
        self.callDictionary = [NSMutableDictionary dictionaryWithCapacity:100];
        self.noticeDictionary = [NSMutableDictionary dictionaryWithCapacity:100];
        [self addObserver:self forKeyPath:@"normalApi" options:(NSKeyValueObservingOptionNew) context:nil];
        _normalApi = 1;
        _dataBaseApi = -1;
        _networkBroadCastApi = -1;
        _historyApi = -1;
        _connectedUrl = url;
        _closeCallBack = closedCallBack;
        
        self.sendLock = [[NSLock alloc] init];
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)connectWithTimeOut:(NSTimeInterval)timeOut {
    if ([self.websocket.url.absoluteString isEqualToString:_connectedUrl]  || ![_connectedUrl hasPrefix:@"ws"]) {
        _connectStatus = WebsocketConnectStatusClosed;
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.connectedUrl] cachePolicy:0 timeoutInterval:timeOut];

    self.websocket = [[SRWebSocket alloc] initWithURLRequest:
                   request];
    
    self.websocket.delegate = self;
    
    [self.websocket open];
}

- (NSInteger)currentId {
    [self.lock lock];
    _currentId ++;
    [self.lock unlock];
    return _currentId;
}

- (void)sendWithChainApi:(WebsocketBlockChainApi)chainApi method:(WebsocketBlockChainMethodApi)method params:(UploadParams *)uploadParams callBack:(CallBackModel *)callBack {
    if (self.websocket.readyState != SR_OPEN) {
        NSError *error = [NSError errorWithDomain:@"RPC connection failed. Please check your network" code:SDKErrorCodeNotConnected userInfo:@{@"Error domain":self.connectedUrl}];
        if (callBack.errorResult) {
            callBack.errorResult(error);
        }
        if (self.connectedUrl) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.connectedUrl] cachePolicy:0 timeoutInterval:2];
            self.websocket = [[SRWebSocket alloc] initWithURLRequest:
                              request];
            self.websocket.delegate = self;
            
            [self.websocket open];
        }

        return;
    }
    
    NSInteger sendID = -1;
    
    switch (chainApi) {
        case WebsocketBlockChainApiNormal:
            sendID = self.normalApi;
            break;
        
        case WebsocketBlockChainApiHistory:
            sendID = self.historyApi;
            break;
        case WebsocketBlockChainApiDataBase:
            sendID = self.dataBaseApi;
            break;
        case WebsocketBlockChainApiNetworkBroadcast:
            sendID = self.networkBroadCastApi;
            break;
    }
    
    if (sendID == -1) {
        NSError *error = [NSError errorWithDomain:@"Websocket api id not found" code:SDKErrorCodeApiNotFound userInfo:nil];
        if (callBack.errorResult) callBack.errorResult(error);
        return;
    }
    
    UploadBaseModel *uploadModel = [[UploadBaseModel alloc] init];
    
    uploadModel.identifier = self.currentId;
    
    uploadModel.method = method;
    
    uploadModel.params = uploadParams;
    
    uploadParams.apiId = sendID;
    
    NSDictionary *dic = [uploadModel convertData];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:(NSJSONWritingPrettyPrinted) error:nil];
    
    SDKLog(@"websocket send:%@",[[NSString alloc] initWithData:data encoding:4]);
    
    dispatch_queue_t queue =  dispatch_queue_create("chouheiwaBitshares", NULL);
    
    dispatch_async(queue, ^{
        [self.sendLock lock];
        switch (method) {
            case WebsocketBlockChainMethodApiCall:{
                [self.callDictionary setObject:callBack forKey:@(uploadModel.identifier)];
            }
                break;
            case WebsocketBlockChainMethodApiNotice:{
                [self.callDictionary setObject:callBack forKey:@(uploadModel.identifier)];
                [self.noticeDictionary setObject:callBack forKey:@(uploadModel.identifier)];
            }
                break;
        }
        [self.sendLock unlock];
    
        [self.websocket send:data];
    });
}

#pragma mark SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message {
    SDKLog(@"message:%@\n",message);
    
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingAllowFragments) error:nil];
    
    WebsocketResultModel *result = [WebsocketResultModel modelToDic:jsonDic];
    
    if (result.isNotice) {
        [self.noticeDictionary objectForKey:result.identifier].noticeResult(result.result);
    }else {
        [self.sendLock lock];
        CallBackModel *model = [self.callDictionary objectForKey:result.identifier];
        [self.callDictionary removeObjectForKey:result.identifier];
        [self.sendLock unlock];
        if (!result.error) {
            model.successResult(result.result);
        }else {
            if (model.errorResult) model.errorResult(result.error);
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    _connectStatus = WebsocketConnectStatusConnected;
    
    NSArray *apiNames = @[@"database",@"network_broadcast",@"history"];

    NSArray *apiPropertyNames = @[@"dataBaseApi",@"networkBroadCastApi",@"historyApi"];

    __weak typeof(self) weakSelf = self;

    [apiNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UploadParams *uploadParams = [[UploadParams alloc] init];
        uploadParams.methodName = obj;
        uploadParams.totalParams = @[];

        CallBackModel *callBack = [CallBackModel new];

        [callBack setSuccessResult:^(id result) {
            __strong typeof(self) self = weakSelf;
            [self setValue:result forKey:apiPropertyNames[idx]];
        }];

        [self sendWithChainApi:WebsocketBlockChainApiNormal method:(WebsocketBlockChainMethodApiCall) params:uploadParams callBack:callBack];
    }];
    [self setValue:@(1) forKey:@"normalApi"];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    !self.closeCallBack?:self.closeCallBack(error);
    self.connectStatus = WebsocketConnectStatusClosed;
    [self.websocket closeWithCode:-25 reason:nil];
    
    // 重连
    CCWLog(@"重新连接");
    [self connectWithTimeOut:5];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if (code == -25) return;
    self.connectStatus = WebsocketConnectStatusClosed;
    if (!reason) {
        reason = @"Websocket unknown closed reason";
    }
    !self.closeCallBack?:self.closeCallBack([NSError errorWithDomain:reason code:code userInfo:nil]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([[self valueForKey:@"normalApi"] intValue] == -1) {
        if (self.connectStatus == WebsocketConnectStatusConnected) {
            self.connectStatus = WebsocketConnectStatusClosed;
        }
    }else{
        self.connectStatus = WebsocketConnectStatusConnected;
    }
}

- (void)setConnectStatus:(WebsocketConnectStatus)connectStatus {
    _connectStatus = connectStatus;
    if (self.connectStatusChange) self.connectStatusChange(connectStatus);
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"normalApi"];
}

@end
