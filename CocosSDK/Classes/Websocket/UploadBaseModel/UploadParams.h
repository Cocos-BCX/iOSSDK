//
//  UploadParams.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>

@interface UploadParams : NSObject

@property (nonatomic, assign) NSInteger apiId;

@property (nonatomic, copy) NSString *methodName;

@property (nonatomic, copy) NSArray *totalParams;

- (NSArray *)convertData;

@end
