//
//  ChainObjectId.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

/**
 On the Cocosbcx blockchains there are no addresses, but objects identified by a unique id, an type and a space in the form
 cocosbcx There is no concept of address, but all operations have a unique ID
 example:1.2.6
 */
@interface ChainObjectId : NSObject<ObjectToDataProtocol>

/** ID in block chain */
@property (nonatomic, assign, readonly) NSInteger spaceId;

@property (nonatomic, assign, readonly) NSInteger typeId;

@property (nonatomic, assign, readonly) NSInteger instance;

+ (instancetype)createFromString:(NSString *)string;

- (instancetype)initFromSpaceId:(NSInteger)spaceId typeId:(NSInteger)typeId instance:(NSInteger)instance;

@end
