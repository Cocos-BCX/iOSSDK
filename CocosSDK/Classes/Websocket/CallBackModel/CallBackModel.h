//
//  CallBackModel.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>

@interface CallBackModel : NSObject

@property (nonatomic, copy, nonnull) void(^successResult)(id result);

@property (nonatomic, copy, nullable) void(^errorResult)(NSError *error);

@property (nonatomic, copy, nullable) void(^noticeResult)(id result);

@end
