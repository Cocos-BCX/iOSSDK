//
//  Transaction.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "Transaction.h"
#import "NSDate+UTCDate.h"
#import "CocosOperationContent.h"
#import "CocosPackData.h"
#import "NSData+HashData.h"
#import "NSData+Base16.h"
@implementation Transaction

- (instancetype)init {
    if (self = [super init]) {
        self.extensions = @[];
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    if ([key isEqualToString:@"expiration"]) {
        self.expiration = [NSDate generateFromObject:value];
        return;
    }
    
    if ([key isEqualToString:@"operations"]) {
        NSArray *array = value;
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *dic in array) {
            [mutableArray addObject:[CocosOperationContent generateFromObject:dic]];
        }
        
        self.operations = mutableArray;
        
        return;
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}



+ (instancetype)generateFromObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;

    return [[self alloc] initWithDic:object];
}
//
- (id)generateToTransferObject {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.operations.count];
    
    for (CocosOperationContent *operationContent in self.operations) {
        [array addObject:[operationContent generateToTransferObject]];
    }
    
    return @{@"ref_block_num":@(self.ref_block_num),@"ref_block_prefix":@(self.ref_block_prefix),@"expiration":[self.expiration generateToTransferObject],@"operations":[array copy],@"extensions":self.extensions};
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:200];
    
    [data appendData:[CocosPackData packShort:self.ref_block_num]];
    
    [data appendData:[CocosPackData packInt:self.ref_block_prefix]];
    
    [data appendData:[CocosPackData packDate:self.expiration]];
    
    [data appendData:[CocosPackData packUnsigedInteger:self.operations.count]];
    
    for (CocosOperationContent *content in self.operations) {
        [data appendData:[content transformToData]];
    }
    
    [data appendData:[CocosPackData packUnsigedInteger:self.extensions.count]];
    
    return [data copy];
}

- (void)setRefBlock:(NSString *)refBlock {
    NSData *data = [[NSData alloc] initWithBase16EncodedString:refBlock options:(NSDataBase16DecodingOptionsDefault)];
    
    [data logDataDetail:@"Data"];
    
    int (^endian_reverse_u32)( int x ) = ^(int x) {
        return (((x >> 0x18) & 0xFF)        )
        | (((x >> 0x10) & 0xFF) << 0x08)
        | (((x >> 0x08) & 0xFF) << 0x10)
        | (((x        ) & 0xFF) << 0x18)
        ;
    };
    
    int (^getIntFromRipemd160)(int i,NSData *data) = ^ (int i,NSData *data) {
        Byte *bytes = (Byte *)data.bytes;
        
        return ((bytes[i * 4 + 3] & 0xff) << 24) | ((bytes[i * 4 + 2] & 0xff) << 16) | ((bytes[i * 4 + 1] & 0xff) << 8) | ((bytes[i * 4 ] & 0xff));
    };
    
    int ref_block_num = getIntFromRipemd160(0,data);
    
    int ref_block_prefix = getIntFromRipemd160(1,data);
    
    _ref_block_num = endian_reverse_u32(ref_block_num);
    _ref_block_prefix = ref_block_prefix & -1;
}

@end
