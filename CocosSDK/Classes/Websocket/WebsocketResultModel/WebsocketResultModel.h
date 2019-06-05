//
//  WebsocketResultModel.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>

@interface WebsocketResultModel : NSObject

@property (nonatomic, strong) NSNumber *identifier;

@property (nonatomic, strong) id result;

@property (nonatomic, assign) BOOL isNotice;

@property (nonatomic, strong) NSError *error;

+ (instancetype)modelToDic:(NSDictionary *)dic;

@end
