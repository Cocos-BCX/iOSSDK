//
//  CCWDataBase.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import "CocosDataBase.h"
#import "CocosSetting.h"
#import "CocosDataBase+Account.h"

@implementation CocosDataBase

static CocosDataBase *cocosDataBase = nil;

+ (instancetype)Cocos_shareDatabase {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cocosDataBase = [[CocosDataBase alloc] init];
    });
    return cocosDataBase;
}

- (instancetype)init
{
    if (self = [super init]) {
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:[self dbPath]];
        [self Cocos_CreateAccountTable];
    }
    return self;
}

- (NSString *)dbPath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"CocosSDK.sqlite"];
    SDKLog(@"databasePath :%@",dbPath);
    return dbPath;
}

/**
 Determine whether a table already exists
 @param tablename tablename
 */
- (BOOL)Cocos_isExistTable:(NSString *)tablename
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tablename];
        while ([rs next]){
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count){
                result = NO;
            }else{
                result = YES;
            }
        }
    }];
    return result;
}

@end
