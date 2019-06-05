//
//  SignedTransaction.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "SignedTransaction.h"
#import "CocosPrivateKey.h"
#import "NSData+HashData.h"
#import "NSData+Base16.h"
#import "CocosConfig.h"
//#import "ChainId.h"
#import "CocosOperationContent.h"
#import "CocosBaseOperation.h"
@implementation SignedTransaction

- (instancetype)init {
    if (self = [super init]) {
        self.signatures = @[];
    }
    return self;
}

- (void)signWithPrikey:(CocosPrivateKey *)prikey {
    NSMutableArray *array = [self.signatures mutableCopy];
    
    NSData *data = [self transformToData];
    
    [array addObject:[prikey signedCompact:[data sha256Data] requireCanonical:YES]];
    
    self.signatures = array;
}

+ (instancetype)generateFromObject:(id)object {
    SignedTransaction *transcation = [super generateFromObject:object];
    
    return transcation;
}

- (NSData *)transformToData {
    NSData *sigData = [super transformToData];
    
    NSMutableData *data = [NSMutableData dataWithCapacity:sigData.length + 33];
 
//    ChainId *chainId = [[ChainId alloc] initWithBase16String:[BaseConfig chainId]];
//
//    [data appendData:chainId.keyData];
    
    NSData *chainIdKeyData = [[[NSData alloc] initWithBase16EncodedString:[CocosConfig chainId] options:(NSDataBase16DecodingOptionsDefault)] copy];

    [data appendData:chainIdKeyData];
    
    [data appendData:sigData];
    
    Byte *logByte = (Byte *)[data bytes];
    for(int i = 0; i<[data length]; i++){
//        printf("%i\n",logByte[i]);
    }
    
    return [data copy];
}

- (id)generateToTransferObject {
    NSMutableDictionary *dic = [[super generateToTransferObject] mutableCopy];
    
    dic[@"signatures"] = self.signatures;
    
    return [dic copy];
}

- (NSArray *)needSignedKeys {
    NSMutableArray *array = [NSMutableArray array];
    
    for (CocosOperationContent *content in self.operations) {
        for (CocosPublicKey *publicKey in ((CocosBaseOperation *)content.operationContent).requiredAuthority) {
            if (![array containsObject:publicKey]) {
                [array addObject:publicKey];
            }
        }
    }
    return array;
}

@end
