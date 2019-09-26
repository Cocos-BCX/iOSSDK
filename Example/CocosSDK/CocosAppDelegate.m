//
//  CocosAppDelegate.m
//  CocosSDK
//
//  Created by SYLing on 03/09/2019.
//  Copyright (c) 2019 SYLing. All rights reserved.
//

#import "CocosAppDelegate.h"
#import "CocosSDK.h"

@implementation CocosAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //    url: 'ws://47.93.62.96:8050',
    //    name: 'COCOS节点1',
    //    ip: '47.93.62.96'
    //
    //    url: 'ws://39.96.33.61:8080',
    //    name: 'COCOS节点2',
    //    ip: '39.96.33.61'
    //
    //    url: 'ws://39.96.29.40:8050',
    //    name: 'COCOS节点3',
    //    ip: '39.96.29.40'
    //
    //    url: 'ws://39.106.126.54:8050',
    //    name: 'COCOS节点4',
    //    ip: '39.106.126.54'
    [[CocosSDK shareInstance] Cocos_OpenLog:YES];
//    [[CocosSDK shareInstance] Cocos_ConnectWithNodeUrl:@"ws://39.106.126.54:8050" Fauceturl:@"http://47.93.62.96:3000" TimeOut:2 CoreAsset:@"COCOS" ChainId:@"53b98adf376459cc29e5672075ed0c0b1672ea7dce42b0b1fe5e021c02bda640" ConnectedStatus:^(WebsocketConnectStatus connectStatus) {
//    }];
//
//    [[CocosSDK shareInstance] Cocos_ConnectWithNodeUrl:@"ws://47.93.62.96:8020" Fauceturl:@"http://47.93.62.96:3000" TimeOut:5 CoreAsset:@"COCOS" ChainId:@"9fc429a48b47447afa5e6618fde46d1a5f7b2266f00ce60866f9fdd92236e137" ConnectedStatus:^(WebsocketConnectStatus connectStatus) {
//
//    }];
    // 新的经济模型
    [[CocosSDK shareInstance] Cocos_ConnectWithNodeUrl:@"ws://192.168.90.46:8049" Fauceturl:@"http://47.93.62.96:8041" TimeOut:5 CoreAsset:@"COCOS" ChainId:@"7c9a7b0b1b8cbe56aa3b24da08aaaf6b3b19a293e7446c7f94f0768d6790cdab" ConnectedStatus:^(WebsocketConnectStatus connectStatus) {
    }];
    
    // 旧的经济模型
//    [[CocosSDK shareInstance] Cocos_ConnectWithNodeUrl:@"ws://39.106.126.54:8049" Fauceturl:@"http://47.93.62.96:8041" TimeOut:5 CoreAsset:@"COCOS" ChainId:@"7d89b84f22af0b150780a2b121aa6c715b19261c8b7fe0fda3a564574ed7d3e9" ConnectedStatus:^(WebsocketConnectStatus connectStatus) {
//        
//    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
