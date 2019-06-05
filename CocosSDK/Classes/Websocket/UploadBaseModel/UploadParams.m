//
//  UploadParams.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "UploadParams.h"

@implementation UploadParams

- (NSArray *)convertData {
    return @[@(self.apiId),self.methodName,self.totalParams];
}

@end
