//
//  AccountOptionObject.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class CocosPublicKey;
@class ChainObjectId;
@class VoteIdObject;
@interface AccountOptionObject : NSObject<ObjectToDataProtocol>

@property (nonatomic, strong) CocosPublicKey *memo_key;

@property (nonatomic, strong) ChainObjectId *voting_account;

@property (nonatomic, assign) NSInteger num_witness;

@property (nonatomic, assign) NSInteger num_committee;

@property (nonatomic, copy) NSArray <VoteIdObject *>*votes;

@property (nonatomic, copy) NSArray *extensions;

@end
