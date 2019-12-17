//
//  CocosOperationContent.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosOperationContent.h"
#import "CocosTransferOperation.h"
#import "CocosCallContractOperation.h"
#import "CocosTransferNHOperation.h"
#import "CocosBuyNHOrderOperation.h"
#import "CocosUpdateAccountOperation.h"
#import "CocosUpgradeMemberOperation.h"
#import "CocosDeleteNHOperation.h"
#import "CocosSellNHAssetCancelOperation.h"
#import "CocosSellNHAssetOperation.h"
#import "CocosMortgageGasOperation.h"
#import "CocosClaimVestingBalanceOperation.h"
#import "CocosCreateSonAccountOperation.h"
#import "CocosPackData.h"

typedef NS_ENUM(NSInteger,CocosOperationType) {
    CocosOperationTypeNotFind = -1,
    CocosOperationTypeTransfer = 0,
    CocosOperationTypeCreateAccount = 5,
    CocosOperationTypeVote = 6,
    CocosOperationTypeUpgradeMember = 7,
    CocosOperationTypeClaimVestingBalance = 27,
    CocosOperationTypeCallContract = 35,
    CocosOperationTypeDeleteNHAsset = 41,
    CocosOperationTypeTransferNHAsset = 42,
    CocosOperationTypeSellNHAsset = 43,
    CocosOperationTypeSellNHAssetCancel = 44,
    CocosOperationTypeBuyNHAsset = 45,
    CocosOperationTypeMortgageGas = 54,
    CocosOperationTypeLimitOrderCreate,
};

@implementation CocosOperationContent

+ (NSDictionary *)opertionToTypeDictionary {
    static NSDictionary *dic = nil;
    
    if (!dic) {
        dic = @{
                NSStringFromClass([CocosTransferOperation class]):@(CocosOperationTypeTransfer),
                NSStringFromClass([CocosCreateSonAccountOperation class]):@(CocosOperationTypeCreateAccount),
                NSStringFromClass([CocosUpdateAccountOperation class]):@(CocosOperationTypeVote),
                NSStringFromClass([CocosUpgradeMemberOperation class]):@(CocosOperationTypeUpgradeMember),
                NSStringFromClass([CocosClaimVestingBalanceOperation class]):@(CocosOperationTypeClaimVestingBalance),
                NSStringFromClass([CocosCallContractOperation class]):@(CocosOperationTypeCallContract),
                NSStringFromClass([CocosDeleteNHOperation class]):@(CocosOperationTypeDeleteNHAsset),
                NSStringFromClass([CocosTransferNHOperation class]):@(CocosOperationTypeTransferNHAsset),
                NSStringFromClass([CocosSellNHAssetOperation class]):@(CocosOperationTypeSellNHAsset),
                NSStringFromClass([CocosSellNHAssetCancelOperation class]):@(CocosOperationTypeSellNHAssetCancel),
                NSStringFromClass([CocosBuyNHOrderOperation class]):@(CocosOperationTypeBuyNHAsset),
                NSStringFromClass([CocosMortgageGasOperation class]):@(CocosOperationTypeMortgageGas)
                };
    }
    return dic;
}

+ (NSDictionary *)typeToOperationDictionary {
    static NSDictionary *dic = nil;
    
    if (!dic) {
        dic = @{
//                @(OperationTypeTransfer):NSStringFromClass([TransferOperation class]),
//                @(OperationTypeLimitOrderCreate):NSStringFromClass([LimitOrderCreateOperation class]);
                };
    }
    return dic;
}

- (instancetype)initWithOperation:(CocosBaseOperation *)operation {
    if (self = [super init]) {
        _operationContent = operation;
        
        NSNumber *classType = [[[self class] opertionToTypeDictionary] objectForKey:NSStringFromClass([operation class])];
        
        NSAssert(classType, @"Could'not find type from operation class:%@",NSStringFromClass([operation class]));
        
        _operationType = classType?[classType integerValue]:-1;
    }
    return self;
}

- (instancetype)initWithOperation:(id)operation type:(NSInteger)type{
    if (self = [super init]) {
        _operationContent = operation;
        
        _operationType = type;
    }
    return self;
}

+ (instancetype)generateFromObject:(NSArray *)object {
    if (![object isKindOfClass:[NSArray class]]) return nil;
    
    if (object.count < 2) return nil;
    
    NSInteger type = [object[0] integerValue];
    
    id content = object[1];
    
    NSString *className = [[self typeToOperationDictionary] objectForKey:@(type)];
    
    if (className) {
        content = [NSClassFromString(className) performSelector:@selector(generateFromObject:) withObject:content];
    }
    
    return [[self alloc] initWithOperation:content type:type];
}

- (id)generateToTransferObject {
    id content = self.operationContent;
    
    if ([self.operationContent isKindOfClass:[CocosBaseOperation class]]) {
        CocosBaseOperation *baseOperation = self.operationContent;
        
        content = [baseOperation generateToTransferObject];
    }
    
    return @[@(self.operationType),content];
}

- (NSData *)transformToData {
    if ([self.operationContent isKindOfClass:[CocosBaseOperation class]]) {
        CocosBaseOperation *baseOperation = self.operationContent;
        NSData *data = [baseOperation transformToData];
        
        NSMutableData *finaData = [NSMutableData dataWithCapacity:data.length + 10];
        
        [finaData appendData:[CocosPackData packUnsigedInteger:self.operationType]];
        
        [finaData appendData:data];
        
        return [finaData copy];
    }
    
    return nil;
}

@end
