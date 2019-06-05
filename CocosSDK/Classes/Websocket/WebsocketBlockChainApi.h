//
//  WebsocketBlockChainApi.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,WebsocketBlockChainApi) {
    WebsocketBlockChainApiNormal = 1,   //
    WebsocketBlockChainApiDataBase,     //
    WebsocketBlockChainApiNetworkBroadcast,
    WebsocketBlockChainApiHistory
};

typedef NS_ENUM(NSInteger,WebsocketConnectStatus) {
    WebsocketConnectStatusClosed,       // Block chain nodes are not linked
    WebsocketConnectStatusConnecting,   // Block Chain Nodes Connecting
    WebsocketConnectStatusConnected     // Block chain nodes are connected
};
