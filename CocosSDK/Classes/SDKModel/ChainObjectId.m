//
//  ChainObjectId.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainObjectId.h"
#import "CocosPackData.h"
@implementation ChainObjectId

+ (instancetype)createFromString:(NSString *)string {
    NSArray *array = [string componentsSeparatedByString:@"."];
    
    if (array.count != 3) return nil;
    
    return [[self alloc] initFromSpaceId:[array[0] integerValue] typeId:[array[1] integerValue] instance:[array[2] integerValue]];
}

- (instancetype)initFromSpaceId:(NSInteger)spaceId typeId:(NSInteger)typeId instance:(NSInteger)instance {
    if (self = [super init]) {
        _spaceId = spaceId;
        _typeId = typeId;
        _instance = instance;
    }
    return self;
}

+ (instancetype)generateFromObject:(NSString *)object {
    if (![object isKindOfClass:[NSString class]]) return nil;
    
    NSArray *array = [object componentsSeparatedByString:@"."];
    
    if (array.count != 3) return nil;
    
    return [[self alloc] initFromSpaceId:[array[0] integerValue] typeId:[array[1] integerValue] instance:[array[2] integerValue]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%ld.%ld.%ld",(long)self.spaceId,(long)self.typeId,(long)self.instance];
}

- (id)generateToTransferObject {
    return self.description;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return [self isEqual:[ChainObjectId generateFromObject:object]];
    }
    
    if ([object isKindOfClass:[self class]]) {
        ChainObjectId *obj = object;
        
        return obj.typeId == self.typeId && obj.spaceId == self.spaceId && obj.instance == self.instance;
    }
    
    return false;
}

- (NSData *)transformToData {
    return [CocosPackData packLongValue:self.instance];
}

@end
