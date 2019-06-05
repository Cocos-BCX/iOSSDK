//
//  WebsocketResultModel.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "WebsocketResultModel.h"
#import "WebsocketResultErrorParse.h"
@implementation WebsocketResultModel

+ (instancetype)modelToDic:(NSDictionary *)dic {
    return [[self alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    if ([key isEqualToString:@"error"]) {
        [super setValue:[WebsocketResultErrorParse generateFromError:value] forKey:key];
        return;
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.identifier = value;
        
        return;
    }
    
    if ([key isEqualToString:@"params"]) {
        
        self.isNotice = true;
        
        NSArray *array = value;
        
        self.identifier = array.firstObject;
        
        self.result = ((NSArray *)array.lastObject).firstObject;
        
        return;
    }
}

@end
