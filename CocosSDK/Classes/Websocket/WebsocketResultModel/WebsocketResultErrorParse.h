//
//  WebsocketResultErrorParse.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//


#import <Foundation/Foundation.h>

@interface WebsocketResultErrorParse : NSObject

+ (NSError *)generateFromError:(NSDictionary *)errorDic;

@end
