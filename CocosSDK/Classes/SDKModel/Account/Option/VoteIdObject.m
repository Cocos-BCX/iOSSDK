//
//  VoteIdObject.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "VoteIdObject.h"
#import "ChainObjectId.h"
#import "CocosPackData.h"
@implementation VoteIdObject


- (instancetype)initWithVoteIdType:(VoteIdType)voteType voteId:(ChainObjectId *)voteId {
    if (self = [ super init]) {
        _voteId = voteId;
        _voteType = voteType;
    }
    return self;
}

+ (instancetype)generateFromObject:(NSString *)object {
    if (![object isKindOfClass:[NSString class]]) return nil;
    
    NSArray *array = [object componentsSeparatedByString:@":"];
    
    VoteIdType type = [array.firstObject intValue];
    
    ChainObjectId *objcId = [[ChainObjectId alloc] initFromSpaceId:1 typeId:6 instance:[array.lastObject integerValue]];
    
    return [[self alloc] initWithVoteIdType:type voteId:objcId];
}

- (id)generateToTransferObject {
    return [NSString stringWithFormat:@"%d:%ld",_voteType,_voteId.instance];
}

- (NSData *)transformToData {
    return [CocosPackData packUnsigedInteger:_voteId.instance];
}

@end
