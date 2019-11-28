//
//  ChainEncryptionMemo.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "ChainEncryptionMemo.h"
#import "CocosPublicKey.h"
#import "CocosPrivateKey.h"
#import "NSData+HashData.h"
#import "NSData+CopyWithRange.h"
#import "NSData+Base16.h"
#import "CocosPackData.h"

@interface ChainEncryptionMemo ()

@property (nonatomic, copy) NSString *nonce;

@property (nonatomic, copy) NSData *message;

@end

@implementation ChainEncryptionMemo

- (instancetype)initWithPrivateKey:(CocosPrivateKey *)priKey anotherPublickKey:(CocosPublicKey *)anotherPubKey customerNonce:(NSString *)customerNonce totalMessage:(NSString *)totalMessage {
    if (self = [super init]) {
        
        if ([customerNonce integerValue] == 0) {
            customerNonce = [NSString stringWithFormat:@"%u",arc4random()];
        }
        
        _nonce = customerNonce;
        
        _from = [priKey publicKey];
        _to = anotherPubKey;
        
        NSData *sha512SharedSecret = [priKey getSharedSecret:anotherPubKey];
        
        NSString *strNoncePlusSecret = [sha512SharedSecret base16EncodedStringWithOptions:(NSDataBase16EncodingOptionsLowerCase)];
        
        NSMutableData *customData = [[[NSString stringWithFormat:@"%@%@",_nonce,strNoncePlusSecret] dataUsingEncoding:NSASCIIStringEncoding] copy];
        
        sha512SharedSecret = [customData sha512Data];
        
        NSData *plainTestData = [totalMessage dataUsingEncoding:NSUTF8StringEncoding];
        
        NSData *checkSumData = [[plainTestData sha256Data] copyWithRange:NSMakeRange(0, 4)];
        
        customData = [NSMutableData dataWithCapacity:checkSumData.length + plainTestData.length];
        
        [customData appendData:checkSumData];
        
        [customData appendData:plainTestData];
        
        NSData *keyData = [sha512SharedSecret copyWithRange:NSMakeRange(0, 32)];
        
        NSData *ivData = [sha512SharedSecret copyWithRange:NSMakeRange(32, 16)];
        
        self.message = [customData aes256Encrypt:keyData ivData:ivData];
    }
    return self;
}

- (NSString *)getMessageWithPrivateKey:(CocosPrivateKey *)privateKey {
    
    NSData *sha512SharedSecret = nil;
    
    if ([privateKey.publicKey isEqual:_from]) {
        sha512SharedSecret = [privateKey getSharedSecret:_to];
    }else if ([privateKey.publicKey isEqual:_to]) {
        sha512SharedSecret = [privateKey getSharedSecret:_from];
    }
    
    NSString *strNoncePlusSecret = [sha512SharedSecret base16EncodedStringWithOptions:(NSDataBase16EncodingOptionsLowerCase)];
    
    NSMutableData *customData = [[[NSString stringWithFormat:@"%@%@",_nonce,strNoncePlusSecret] dataUsingEncoding:NSASCIIStringEncoding] copy];
    
    sha512SharedSecret = [customData sha512Data];
    
    if (!sha512SharedSecret) return nil;
    
    NSData *keyData = [sha512SharedSecret copyWithRange:NSMakeRange(0, 32)];
    
    NSData *ivData = [sha512SharedSecret copyWithRange:NSMakeRange(32, 16)];
    
    NSData *decryptData = [self.message aes256Decrypt:keyData ivData:ivData];
    
    if (!decryptData) return nil;
    
    NSData *checkSumData = [decryptData copyWithRange:NSMakeRange(0, 4)];
    
    NSData *messageData = [decryptData copyWithRange:NSMakeRange(4, decryptData.length - 4)];
    
    NSData *sha256Data = [messageData sha256Data];
    
    if (![[sha256Data copyWithRange:NSMakeRange(0, 4)] isEqualToData:checkSumData]) return nil;
    
    return [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) return;
    
    if ([key isEqualToString:@"from"]) {
        _from = [[CocosPublicKey alloc] initWithAllPubkeyString:value];
        
        return;
    }
    
    if ([key isEqualToString:@"to"]) {
        _to = [[CocosPublicKey alloc] initWithAllPubkeyString:value];
        
        return;
    }
    
    if ([key isEqualToString:@"message"]) {
        NSString *sign = value;
        
        _message = [[NSData alloc] initWithBase16EncodedString:sign options:0];
        
        return;
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

+ (instancetype)generateFromObject:(NSDictionary *)object {
    if (![object isKindOfClass:[NSDictionary class]]) return nil;
    
    ChainEncryptionMemo *memo = [[ChainEncryptionMemo alloc] init];

    [ChainEncryptionMemo setValuesForKeysWithDictionary:object];
    
    return memo;
}

- (id)generateToTransferObject {
    return @{@"from":_from.description,@"to":_to.description,@"nonce":_nonce,@"message":[_message base16EncodedStringWithOptions:(NSDataBase16EncodingOptionsLowerCase)]};
}

- (NSData *)transformToData {
    NSMutableData *data = [NSMutableData dataWithCapacity:200];
    
    [data appendData:self.from.keyData];
    
    [data appendData:self.to.keyData];

    NSDecimalNumber *de = [NSDecimalNumber decimalNumberWithString:self.nonce];
    
    long value = [de longValue];
    
    NSData *nonceData = [CocosPackData packLongValue:value];
    
    [data appendData:nonceData];
    
    [data appendData:[CocosPackData packUnsigedInteger:self.message.length]];
    
    [data appendData:self.message];
    
    return [data copy];
}

@end
