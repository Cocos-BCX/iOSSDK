//
//  NSDate+UTCDate.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "NSDate+UTCDate.h"
#import "CocosPackData.h"

@implementation NSDate (UTCDate)

+ (instancetype)generateFromObject:(id)object {
    if (![object isKindOfClass:[NSString class]]) return nil;
    
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    
    matter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];;
    
    matter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    
    NSDate *date = [matter dateFromString:object];
    
    return date;
}

- (id)generateToTransferObject {
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    
    matter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];;
    
    matter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    
    NSString *date = [matter stringFromDate:self];
    
    return date;
}

- (NSData *)transformToData {
    return [CocosPackData packDate:self];
}

@end
