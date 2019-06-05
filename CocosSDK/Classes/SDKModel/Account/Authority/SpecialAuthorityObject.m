//
//  SpecialAuthorityObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "SpecialAuthorityObject.h"

@implementation SpecialAuthorityObject

+ (instancetype)generateFromObject:(NSArray *)object {
    if (![object isKindOfClass:[NSArray class]]) return nil;
    
    SpecialAuthorityObject *obj = [[SpecialAuthorityObject alloc] init];
    
    obj.weight_threshold = [object.firstObject integerValue];
    
    obj.item = object.lastObject;
    
    return obj;
}

- (id)generateToTransferObject {
    return @[@(self.weight_threshold),self.item];
}

@end
