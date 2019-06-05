//
//  ObjectToDataProtocol.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//
//  Link Chain Sending Data Conversion, Protocol

#import <Foundation/Foundation.h>

@protocol ObjectToDataProtocol <NSObject>

/**
 Generating Dictionary for Websocket Broadcasting

 @return NSString | NSDictionary | NSArray
 */
- (id)generateToTransferObject;

/**
 Obtaining object transformation from websocket

 @param object NSString | NSDictionary | NSArray Class
 @return This object
 */
+ (instancetype)generateFromObject:(id)object;

@optional

- (NSData *)transformToData;

@end
