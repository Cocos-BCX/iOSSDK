//
//  ChainAccountModel.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "ObjectToDataProtocol.h"
@class ChainObjectId,AuthorityObject,AccountOptionObject,SpecialAuthorityObject
,CocosPublicKey;

@interface ChainAccountModel : NSObject<ObjectToDataProtocol>

/** 账户id(唯一标识) */
@property (nonatomic, strong) ChainObjectId *identifier;
/** 会员过期日期 */
@property (nonatomic, strong) NSDate *membership_expiration_date;
/** 账户注册人(当和id一致时这个用户是终身会员) */
@property (nonatomic, strong) ChainObjectId *registrar;
/** 推荐人 */
@property (nonatomic, strong) ChainObjectId *referrer;
/** 终身推荐人 */
@property (nonatomic, strong) ChainObjectId *lifetime_referrer;
/** 网络费用百分比 */
@property (nonatomic, assign) NSInteger network_fee_percentage;
/** 推荐人费用百分比 */
@property (nonatomic, assign) NSInteger lifetime_referrer_fee_percentage;
/** 推荐人奖励比例 */
@property (nonatomic, assign) NSInteger referrer_rewards_percentage;
/**  账户名 */
@property (nonatomic, copy) NSString *name;
/** <#Description#> */
@property (nonatomic, strong) AuthorityObject *owner;
/** <#Description#> */
@property (nonatomic, strong) AuthorityObject *active;
/** <#Description#> */
@property (nonatomic, strong) AccountOptionObject *options;
/** 账户统计 ID */
@property (nonatomic, strong) ChainObjectId *statistics;
/** 白名单账户 */
@property (nonatomic, strong) NSArray <ChainObjectId *>*whitelisting_accounts;
/** 黑名单账户 */
@property (nonatomic, strong) NSArray <ChainObjectId *>*blacklisting_accounts;
/** 历史白名单账户 */
@property (nonatomic, strong) NSArray <ChainObjectId *>*whitelisted_accounts;
/** 历史黑名单账户 */
@property (nonatomic, strong) NSArray <ChainObjectId *>*blacklisted_accounts;
/** 现金返还 */
@property (nonatomic, strong) ChainObjectId *cashback_vb;
/** 账户特殊授权 */
@property (nonatomic, strong) SpecialAuthorityObject *owner_special_authority;
/** 资金特殊授权 */
@property (nonatomic, strong) SpecialAuthorityObject *active_special_authority;
/**
 This flag is set when the top_n logic sets both
 authorities, and gets reset when authority or special_authority is set.
 */
@property (nonatomic, assign) NSInteger top_n_control_flagcreation_dates;

- (BOOL)containPublicKey:(CocosPublicKey *)publicKey;

@end
