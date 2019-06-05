//
//  CocosOperationContent.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class CocosBaseOperation;

@interface CocosOperationContent : NSObject<ObjectToDataProtocol>

@property (nonatomic, assign, readonly) NSInteger operationType;

@property (nonatomic, strong, readonly) id operationContent;

- (instancetype)initWithOperation:(CocosBaseOperation *)operation;

@end
