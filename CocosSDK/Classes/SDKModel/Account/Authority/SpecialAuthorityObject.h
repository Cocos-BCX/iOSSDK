//
//  SpecialAuthorityObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"

@interface SpecialAuthorityObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, assign) NSInteger weight_threshold;

@property (nonatomic, copy) NSDictionary *item;

@end
