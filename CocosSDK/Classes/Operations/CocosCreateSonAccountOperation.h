//
//  CocosCreateSonAccountOperation.h
//  CocosSDKDemo
//
//  Created by 邵银岭 on 2019/11/19.
//  Copyright © 2019 邵银岭. All rights reserved.
//

#import "CocosBaseOperation.h"

@class ChainObjectId,AuthorityObject,AccountOptionObject;

NS_ASSUME_NONNULL_BEGIN

@interface CocosCreateSonAccountOperation : CocosBaseOperation

@property (nonatomic, strong, nonnull) ChainObjectId *registrar;

@property (nonatomic, copy, nonnull) NSString *name;

/** <#Description#> */
@property (nonatomic, strong) AuthorityObject *owner;
/** <#Description#> */
@property (nonatomic, strong) AuthorityObject *active;
/** <#Description#> */
@property (nonatomic, strong) AccountOptionObject *options;

@property (nonatomic, strong, nonnull) NSArray *extensions;

@end

NS_ASSUME_NONNULL_END
