//
//  NSObject+DataToObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "NSObject+DataToObject.h"
#import <objc/runtime.h>
#include <string.h>
#import "ObjectToDataProtocol.h"

@implementation NSObject (DataToObject)

- (id)defaultGetValue:(id)value forKey:(NSString *)key {
    NSDictionary *dic = [[self class] getPropertyType];
    
    NSString *className = dic[key];
    
    if (className) {
        Class <ObjectToDataProtocol>class = NSClassFromString(className);
        
        if ([class respondsToSelector:@selector(generateFromObject:)]) {
            return [class generateFromObject:value];
        }
        
        if ([className isEqualToString:NSStringFromClass([NSDecimalNumber class])]) {
            return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",value]];
        }
    }
    return value;
}

- (NSDictionary *)defaultGetDictionary {
    NSArray *array = [[self class] getPropertyNameArray];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:array.count];
    
    for (NSString *key in array) {
        id <ObjectToDataProtocol> obj = [self valueForKey:key];
        
        if ([obj respondsToSelector:@selector(generateToTransferObject)]) {
            dic[key] = [obj generateToTransferObject];
            continue;
        }
        
        if ([obj isKindOfClass:[NSDecimalNumber class]]) {
            dic[key] = ((NSDecimalNumber *)obj).stringValue;
            continue;
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            dic[key] = [NSObject generateToTransferArray:(NSArray *)obj];
            continue;
        }
        dic[key] = obj;
    }
    return [dic copy];
}

/**
 * Get the data type of a property in a class
 * @designatedClass, designated class name of `Class`
 */
+ (NSDictionary *)getPropertyType {
    unsigned int outCount = 0, i = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:outCount];
    for (; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *property_name = property_getName(property);
        const char * property_attr = property_getAttributes(property);
        
        NSString *property_data_type = nil;
        //If the property is a type of Objective-C class, then substring the variable of `property_attr` in order to getting its real type
        if (property_attr[1] == '@') {
            NSString *property =  [NSString stringWithUTF8String:property_attr];
            
            NSRange range = [property rangeOfString:@"@\".+\"" options:NSRegularExpressionSearch];
            
            range.location += 2;
            range.length -= 3;
            
            property_data_type = [property substringWithRange:range];
            dic[[NSString stringWithUTF8String:property_name]] = property_data_type;
        }
    }
    return [dic copy];
}

+ (NSArray *)generateFromDataArray:(NSArray *)dataArray {
    if ([self respondsToSelector:@selector(generateFromObject:)]) {
        Class <ObjectToDataProtocol>className = [self class];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:dataArray.count];
        
        for (id object in dataArray) {
            [array addObject:[className generateFromObject:object]];
        }
        
        return [array copy];
    }
    return nil;
}

+ (NSArray *)generateToTransferArray:(NSArray *)objectArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:objectArray.count];
    
    [objectArray enumerateObjectsUsingBlock:^(id <ObjectToDataProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(generateToTransferObject)]) {
            [array addObject:[obj generateToTransferObject]];
        }else {
            [array addObject:obj];
        }
    }];
    return [array copy];
}

+ (NSArray *)getPropertyNameArray {
    unsigned int outCount = 0, i = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    static NSArray *avoidArray = nil;
    
    if (!avoidArray) {
        avoidArray = @[@"debugDescription",@"description",@"hash",@"superclass"];
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:outCount];
    for (; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *property_name = property_getName(property);
    
        //If the property is a type of Objective-C class, then substring the variable of `property_attr` in order to getting its real typ
        NSString *keyName = [NSString stringWithFormat:@"%s",property_name];
        
        if ([avoidArray containsObject:keyName]) continue;
        
        [array addObject:keyName];
    }
    return [array copy];
}

/**
 * Get the data type of a property in a class that the encode characters is deponding on the following Link
 * https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 **/
- (char *)getPropertyRealType:(const char *)property_attr {
    char * type;
    
    char t = property_attr[1];
    
    if (strcmp(&t, @encode(char)) == 0) {
        type = "char";
    } else if (strcmp(&t, @encode(int)) == 0) {
        type = "int";
    } else if (strcmp(&t, @encode(short)) == 0) {
        type = "short";
    } else if (strcmp(&t, @encode(long)) == 0) {
        type = "long";
    } else if (strcmp(&t, @encode(long long)) == 0) {
        type = "long long";
    } else if (strcmp(&t, @encode(unsigned char)) == 0) {
        type = "unsigned char";
    } else if (strcmp(&t, @encode(unsigned int)) == 0) {
        type = "unsigned int";
    } else if (strcmp(&t, @encode(unsigned short)) == 0) {
        type = "unsigned short";
    } else if (strcmp(&t, @encode(unsigned long)) == 0) {
        type = "unsigned long";
    } else if (strcmp(&t, @encode(unsigned long long)) == 0) {
        type = "unsigned long long";
    } else if (strcmp(&t, @encode(float)) == 0) {
        type = "float";
    } else if (strcmp(&t, @encode(double)) == 0) {
        type = "double";
    } else if (strcmp(&t, @encode(_Bool)) == 0 || strcmp(&t, @encode(bool)) == 0) {
        type = "BOOL";
    } else if (strcmp(&t, @encode(void)) == 0) {
        type = "void";
    } else if (strcmp(&t, @encode(char *)) == 0) {
        type = "char *";
    } else if (strcmp(&t, @encode(id)) == 0) {
        type = "id";
    } else if (strcmp(&t, @encode(Class)) == 0) {
        type = "Class";
    } else if (strcmp(&t, @encode(SEL)) == 0) {
        type = "SEL";
    } else if (strcmp(&t, @encode(NSInteger)) == 0){
        type = "NSInteger";
    }else {
        type = "";
    }
    return type;
}

@end
