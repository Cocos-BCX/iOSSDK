//
//  NSObject+DataToObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>

@interface NSObject (DataToObject)

+ (NSDictionary *)getPropertyType;

+ (NSArray *)getPropertyNameArray;

+ (NSArray *)generateFromDataArray:(NSArray *)dataArray;

+ (NSArray *)generateToTransferArray:(NSArray *)objectArray;

- (id)defaultGetValue:(id)value forKey:(NSString *)key;

- (NSDictionary *)defaultGetDictionary;

@end
