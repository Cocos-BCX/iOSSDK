//
//  CCWDataBase.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/1.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@class CocosDataBase;

@interface CocosDataBase : NSObject
{
    FMDatabaseQueue *_dataBaseQueue;
}

+ (instancetype)Cocos_shareDatabase;

/**
 Determine whether a table already exists
 @param tablename tablename
 */
- (BOOL)Cocos_isExistTable:(NSString *)tablename;
@end
