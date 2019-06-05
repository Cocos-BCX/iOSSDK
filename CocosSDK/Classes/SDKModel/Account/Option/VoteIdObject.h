//
//  VoteIdObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
typedef NS_ENUM(int,VoteIdType) {
    VoteIdTypeCommitteeMember,
    VoteIdTypeWitness,
};

@class ChainObjectId;

@interface VoteIdObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, assign, readonly) VoteIdType voteType;
/**
 voteId is @"1.6.???"
 */
@property (nonatomic, strong, readonly) ChainObjectId *voteId;

- (instancetype)initWithVoteIdType:(VoteIdType)voteType voteId:(ChainObjectId *)voteId;

@end
