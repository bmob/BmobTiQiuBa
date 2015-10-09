//
//  NoticeManager.m
//  SportsContact
//
//  Created by bobo on 14-8-15.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "NoticeManager.h"
#import <FMDB/FMDB.h>
#import "FCFileManager.h"
#import <BmobSDK/Bmob.h>
#import "AppSettings.h"
#import "TeamEngine.h"

#import "BPushUtil.h"

#define kSQLInteger @"integer"
#define kSQLText @"text"
#import "Util.h"

@interface NoticeManager()

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation NoticeManager

typedef NS_OPTIONS(NSInteger, NoticeColumn) {
    NoticeColumnObjectId = 0,
    NoticeColumnAps,
    NoticeColumnBelongId,
    NoticeColumnTargetId,
    NoticeColumnTitle,
//    NoticeColumnContent,
    NoticeColumnTime,
    NoticeColumnType,
    NoticeColumnSubtype,
    NoticeColumnStatus,
    NoticeColumnExtra,
    NoticeColumnNum
};

static NSString* gNoticeColumnsName[NoticeColumnNum];
static NSString* gNoticeColumnsType[NoticeColumnNum];

+ (instancetype)sharedManager
{
    static NoticeManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[[self class] alloc] init];
        gNoticeColumnsName[NoticeColumnObjectId] = @"objectId";
        gNoticeColumnsType[NoticeColumnObjectId] = kSQLText;
        gNoticeColumnsName[NoticeColumnAps] = @"aps";
        gNoticeColumnsType[NoticeColumnAps] = kSQLText;
        gNoticeColumnsName[NoticeColumnBelongId] = @"belongId";
        gNoticeColumnsType[NoticeColumnBelongId] = kSQLText;
        gNoticeColumnsName[NoticeColumnTargetId] = @"targetId";
        gNoticeColumnsType[NoticeColumnTargetId] = kSQLText;
        gNoticeColumnsName[NoticeColumnTitle] = @"title";
        gNoticeColumnsType[NoticeColumnTitle] = kSQLText;
//        gNoticeColumnsName[NoticeColumnContent] = @"content";
//        gNoticeColumnsType[NoticeColumnContent] = kSQLText;
        gNoticeColumnsName[NoticeColumnTime] = @"time";
        gNoticeColumnsType[NoticeColumnTime] = kSQLInteger;
        gNoticeColumnsName[NoticeColumnType] = @"type";
        gNoticeColumnsType[NoticeColumnType] = kSQLInteger;
        gNoticeColumnsName[NoticeColumnSubtype] = @"subtype";
        gNoticeColumnsType[NoticeColumnSubtype] = kSQLInteger;
        gNoticeColumnsName[NoticeColumnStatus] = @"status";
        gNoticeColumnsType[NoticeColumnStatus] = kSQLInteger;
        gNoticeColumnsName[NoticeColumnExtra] = @"extra";
        gNoticeColumnsType[NoticeColumnExtra] = kSQLText;
    });
    return _sharedManager;
}

+ (void)updatePushProfile
{
    NSData *deviceToken =[AppSettings dataOfKey:SettingsDeviceToken];
    if (deviceToken)
    {
//        NSString *uid = @"";
        if ([BmobUser getCurrentUser])
        {
            BmobUser *currentUser = [BmobUser getCurrentUser];
//            uid                   = [[BmobUser getCurrentUser] objectForKey:@"username"];
            [currentUser setObject:@"ios" forKey:@"deviceType"];
            [currentUser setObject:[AppSettings stringOfKey:SettingBPushChannelid] forKey:@"pushChannelId"];
            [currentUser setObject:[AppSettings stringOfKey:SettingBPushUserId] forKey:@"pushUserId"];
            [currentUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                
            }];
            
        }
        
       
        
        
//        NSString *token = [[[deviceToken description]
//                            stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
//                           stringByReplacingOccurrencesOfString:@" "
//                           withString:@""];
//        BmobQuery *bquery = [BmobInstallation query];
//        [bquery whereKey:@"deviceToken" equalTo:token];
//        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
//         {
//             if (!error)
//             {
//                 BmobInstallation *installation = [BmobInstallation currentInstallation];
//                 if ([array count] > 0)
//                 {
//                     installation.objectId = [[array firstObject] objectId];
//                     [installation setDeviceToken:nil];
//                     [installation setObject:uid forKey:@"uid"];
//                     [installation updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
//                      {
//                          if (error)
//                          {
//                              BDLog(@"Update installation error %@", error);
//                          }
//                      }];
//                 }else
//                 {
//                     [installation setDeviceTokenFromData:deviceToken];
//                     [installation setObject:uid forKey:@"uid"];
//                     [installation saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
//                      {
//                          if (error)
//                          {
//                              BDLog(@"Save installation error %@", error);
//                          }
//                      }];
//                 }
//             }
//         }];
    }
}


- (void)bindDB
{
    if (![BmobUser getCurrentUser]) {
        return ;
    }
    NSString *filename = [NSString stringWithFormat:@"%@.sqlite", [[BmobUser getCurrentUser] objectForKey:@"username"]];
    NSString *dbPath = [FCFileManager pathForDocumentsDirectoryWithPath:filename];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [self setQueue:queue];
    BDLog(@"bindDB file path : %@", dbPath);
    [Util addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dbPath]];
    // 建表：消息列表
    [queue inDatabase:^(FMDatabase *db) {
        db.logsErrors = NO;
        NSMutableString *parma = [[NSMutableString alloc] init];
        for (int i =0; i<NoticeColumnNum; i++)
        {
            [parma appendFormat:@"%@ %@", gNoticeColumnsName[i], gNoticeColumnsType[i]];
            
//            if (i == NoticeColumnObjectId)
//            {
//                [parma appendString:@" PRIMARY KEY autoincrement"];
//            }
            if (i < NoticeColumnNum - 1)
            {
                [parma appendString:@", "];
            }
        }
        NSString *executeString = [NSString stringWithFormat:@"CREATE TABLE %@ (%@)", kTableNotice, parma];
        BOOL isSuccess = [db executeUpdate:executeString];
        //  如果表已经存在，把每一列插入一遍，防止升级修改数据库
        if (isSuccess == NO)
        {
            for (int i =0; i<NoticeColumnNum; i++)
            {
                [self _excuteAddColumnStatementToDB:db column:gNoticeColumnsName[i] type:gNoticeColumnsType[i] ifNotExistInTable:kTableNotice];
            }
        }
        db.logsErrors = YES;
    }];
}

- (void)unbindDB
{
    [self.queue close];
    [self setQueue:nil];
}

- (void)saveNotice:(Notice *)aNotice
{
    [self.queue inDatabase:^(FMDatabase *db)
     {
         NSString *contidtion = [NSString stringWithFormat:@"%@ = '%@'", gNoticeColumnsName[NoticeColumnObjectId], aNotice.objectId];
         FMResultSet *resultSet = [self _excuteQueryExistToDB:db contidtion:contidtion atTable:kTableNotice];
         if ([resultSet next])
         {
             [resultSet close];
             NSMutableDictionary *dic = [self _convertNoticeDic:[aNotice getDictionary]];
//             [dic removeObjectForKey:@"status"];
             [dic setObject:@(NoticeStatusReceived) forKey:@"status"];
             
             [self _excuteUpdateStatementToDB:db fromDic:dic condition:contidtion atTable:kTableNotice];
         }else
         {
             [resultSet close];
             NSMutableDictionary *dic = [self _convertNoticeDic:[aNotice getDictionary]];
//             [dic removeObjectForKey:@"status"];
             [dic setObject:@(NoticeStatusReceived) forKey:@"status"];
             [self _excuteInsertStatementToDB:db fromDic:dic atTable:kTableNotice];
         }
         
     }];
}

- (void)pushNotice:(Notice *)aNotice toUsername:(NSString *)username block:(EngineBlock()) engineBlock;
{
//    BmobObject *pushObject = [BmobObject objectWithClassName:kTablePushMsg];
//    [pushObject setObject:@"" forKey:@"belongId"];
//    [pushObject setObject:@"" forKey:@"belongNick"];
//    [pushObject setObject:username forKey:@"belongUsername"];
//    [pushObject setObject:aNotice.aps.alert forKey:@"content"];
//    [pushObject setObject:[NSNumber numberWithInteger:[[NSNumber numberWithBool:NO] integerValue]] forKey:@"isRead"];
//    [pushObject setObject:[NSNumber numberWithInteger:0] forKey:@"status"];
//    [pushObject setObject:[NSNumber numberWithInteger:0] forKey:@"msgType"];
//    NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:[aNotice getDictionary]];
//    [extraDic removeObjectForKey:@"aps"];
//    [extraDic removeObjectForKey:@"objectId"];
//    [extraDic removeObjectForKey:@"status"];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extraDic options:0 error:NULL];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    [pushObject setObject:jsonString forKey:@"extra"];
//    
//    [pushObject saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
//     {
//         if (engineBlock) {
//             engineBlock(nil, error);
//         }
//         if (isSuccessful) {
//             BmobPush *push = [BmobPush push];
//             BmobQuery *query = [BmobInstallation query];
//             [query whereKey:@"uid" equalTo:username];
//             [push setQuery:query];
//             aNotice.objectId =pushObject.objectId;
//             //            [[NoticeManager sharedManager] saveNotice:aNotice];
//             aNotice.aps.badge = 1;
//             NSMutableDictionary *pushDic = [NSMutableDictionary dictionaryWithDictionary:[aNotice getDictionary]];
//             [pushDic removeObjectForKey:@"status"];
//             [pushDic removeObjectForKey:@"extra"];
//             [pushDic setObject:SettingsPushFlagvalueNotice forKey:SettingsPushFlag];
//             [push setData:pushDic];
//             BDLog(@"******send push dictionary******%@", pushDic);
//             [push sendPushInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
//                 if (!isSuccessful)
//                 {
//                     BDLog(@"******send push error******%@", error);
//                 }
//             }];
//         }else
//         {
//             BDLog(@"******save push error******%@", error);
//         }
//     }];
    
    [BPushUtil sendMessageToOne:username notice:aNotice block:engineBlock];
}

- (void)pushNotice:(Notice *)aNotice toUsername:(NSString *)username
{
    if (!username || username.length == 0) {
        return;
    }
    
    Notice *tmpNotice = [[Notice alloc] init];
    tmpNotice = aNotice;
    
    [self pushNotice:tmpNotice toUsername:username block:NULL];
//
    
    BDLog(@"pushNotice username%@" ,tmpNotice);
}

- (void)pushNotice:(Notice *)aNotice toTeam:(NSString *)teamId
{
    BDLog(@"teamId %@",teamId);
    [TeamEngine getTeamMembersWithTeamId:teamId block:^(id result, NSError *error)
    {
       
        for (UserInfo *user in result)
        {
            [self pushNotice:aNotice toUsername:user.username];
        }
    }];
}












- (NSMutableDictionary *)_convertNoticeDic:(NSDictionary *)aDic
{
    NSMutableDictionary *convertDic = [NSMutableDictionary dictionaryWithCapacity:0];
    for (int i = NoticeColumnObjectId; i< NoticeColumnNum; i++)
    {
        NSString *key = gNoticeColumnsName[i];
        id object = [aDic objectForKey:key];
        if (object != nil)
        {
            if ([object isKindOfClass:[NSDictionary class]]) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                object = jsonString;
            }
            [convertDic setObject:object forKey:key];
        }
    }
    return convertDic;
}

- (NSMutableDictionary *)_convertNoticeResult:(FMResultSet *)aResult
{
    NSMutableDictionary *convertDic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i< NoticeColumnNum; i++)
    {
        NSString *key = gNoticeColumnsName[i];
        NSString *type = gNoticeColumnsType[i];
        
        if ([type hasPrefix:kSQLInteger])
        {
            long long object = [aResult longLongIntForColumn:key];
            
            [convertDic setObject:@(object) forKey:key];
        }
        else if([type hasPrefix:kSQLText])
        {
            NSString *object = [aResult stringForColumn:key];
            if (object != nil)
            {
                [convertDic setObject:[NSString stringWithFormat:@"%@", object] forKey:key];
            }
        }
    }
    return convertDic;
}
#pragma mark - 数据更新

- (void)markNoticeDisposed:(Notice *)aNotice
{
    [self.queue inDatabase:^(FMDatabase *db)
    {
        // 更新消息
//        NSString *column = gNoticeColumnsName[NoticeColumnObjectId];
//        NSString *value = [NSString stringWithFormat:@"%@",aNotice.objectId];
        NSString *contidtion = [NSString stringWithFormat:@"%@ = '%@'", gNoticeColumnsName[NoticeColumnObjectId], aNotice.objectId];
        NSDictionary *change = @{gNoticeColumnsName[NoticeColumnStatus]: [NSNumber numberWithInteger:NoticeStatusDisposed]};
        [self _excuteUpdateStatementToDB:db fromDic:change condition:contidtion atTable:kTableNotice];
        
        
        
    }];
}

//-(void)updateAllNoticesRead{
//    [self.queue inDatabase:^(FMDatabase *db)
//     {
//        NSDictionary *change = @{gNoticeColumnsName[NoticeColumnStatus]: [NSNumber numberWithInteger:NoticeStatusRead]};
//        [self _excuteUpdateStatementToDB:db fromDic:change condition:nil atTable:kTableNotice];
//         dispatch_async(dispatch_get_main_queue(), ^{
//             [[NSNotificationCenter defaultCenter] postNotificationName:kObserverUnreadNoticeChanged object:nil];
//         });
//     }];
//}

- (void)markAllNoticesRead
{
    [self.queue inDatabase:^(FMDatabase *db)
     {
         NSString *condition = [NSString stringWithFormat: @"%@ <> %ld",gNoticeColumnsName[NoticeColumnStatus],(long)NoticeStatusDisposed];
         NSDictionary *change = @{gNoticeColumnsName[NoticeColumnStatus]: [NSNumber numberWithInteger:NoticeStatusRead]};
         [self _excuteUpdateStatementToDB:db fromDic:change condition:condition atTable:kTableNotice];
         dispatch_async(dispatch_get_main_queue(), ^{
             [[NSNotificationCenter defaultCenter] postNotificationName:kObserverUnreadNoticeChanged object:nil];
         });
     }];
}

- (void)markNoticesRead:(NSArray *)aNotices
{
    [self.queue inDatabase:^(FMDatabase *db)
     {
         for (Notice *notice in aNotices) {
             NSString *contidtion = [NSString stringWithFormat:@"%@ = '%@'", gNoticeColumnsName[NoticeColumnObjectId], notice.objectId];
             NSDictionary *change = @{gNoticeColumnsName[NoticeColumnStatus]: [NSNumber numberWithInteger:NoticeStatusRead]};
             [self _excuteUpdateStatementToDB:db fromDic:change condition:contidtion atTable:kTableNotice];
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [[NSNotificationCenter defaultCenter] postNotificationName:kObserverUnreadNoticeChanged object:nil];
         });
     }];
}

#pragma mark - 数据删除

- (void)deleteNotice:(Notice *)aNotice
{
    [self.queue inDatabase:^(FMDatabase *db) {
        // 删除消息
        NSString *column = gNoticeColumnsName[NoticeColumnObjectId];
        NSString *value = [NSString stringWithFormat:@"'%@'",aNotice.objectId];
        [self _excuteDeleteToDB:db column:column value:value atTable:kTableNotice];
    }];
}

#pragma mark - 数据读取
- (void)readUnreadCountFinished:(void (^)(NSInteger count))aFinishBlock
{
//    [self.queue close];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *execute = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@ WHERE %@=%ld ", kTableNotice, gNoticeColumnsName[NoticeColumnStatus], (long)NoticeStatusReceived];
        
        FMResultSet *s = [db executeQuery:execute];
        while ([s next])
        {
            NSInteger count = [s intForColumn:@"count"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (aFinishBlock)
                {
                    aFinishBlock(count);
                }
            });
        }
    }];
}

- (void)readNoticeListFromWebFinished:(void (^)(NSArray *noticeList))aFinishBlock
{
    UserInfo *userInfo = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    BmobQuery *query = [BmobQuery queryWithClassName:kTablePushMsg];
    [query whereKey:@"belongUsername" equalTo:userInfo.username];
    [query whereKey:@"isRead" equalTo:[NSNumber numberWithInteger:[[NSNumber numberWithInteger:NO] integerValue]]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         if (error) {
             BDLog(@"Query PushMsg error %@", error);
             if (aFinishBlock)
             {
                 aFinishBlock(nil);
             }
         }else
         {
             
             NSMutableArray *noticeList = [NSMutableArray arrayWithCapacity:0];
             for (BmobObject *item in array) {
                 //                PushMsg *pushMsg = [[PushMsg alloc] initWithDictionary:item];
                 Notice *notice = [[Notice alloc] initWithString:[item objectForKey:@"extra"]];
                 notice.aps = [ApsInfo apsInfoWithAlert:[item objectForKey:@"content"] badge:0 sound:nil];
                 notice.objectId = item.objectId;
                 notice.time = [item.createdAt timeIntervalSince1970];
                 [self saveNotice:notice];
                 [item setObject:[NSNumber numberWithInteger:[[NSNumber numberWithInteger:YES] integerValue]] forKey:@"isRead"];
                 [item updateInBackground];
                 [noticeList addObject:notice];
             }
             if (aFinishBlock)
             {
                 aFinishBlock(noticeList);
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:kObserverUnreadNoticeChanged object:nil];
         }
     }];
}
- (void)readNoticeListFromDiskFinished:(void (^)(NSArray *noticeList))aFinishBlock
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *execute = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", kTableNotice, gNoticeColumnsName[NoticeColumnTime]];
        
        NSMutableArray *noticeList = [NSMutableArray arrayWithCapacity:0];
        FMResultSet *s = [db executeQuery:execute];
        int i = 0;
        while ([s next] && i < 50)
        {
            NSDictionary *dic = [self _convertNoticeResult:s];
            Notice *nti = [[Notice alloc] initWithDictionary:dic];
            [noticeList addObject:nti];
            i ++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self markAllNoticesRead];
            if (aFinishBlock)
            {
                aFinishBlock(noticeList);
            }
            
        });
    }];
}

//- (void)readNoticeListFinished:(void (^)(NSArray *noticeList))aFinishBlock
//{
//    UserInfo *userInfo = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
//    BmobQuery *query = [BmobQuery queryWithClassName:kTablePushMsg];
//    [query whereKey:@"belongUsername" equalTo:userInfo.username];
//    [query whereKey:@"isRead" equalTo:[NSNumber numberWithInteger:[[NSNumber numberWithInteger:NO] integerValue]]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
//    {
//        if (error) {
//            BDLog(@"Query PushMsg error %@", error);
//        }else
//        {
//            for (BmobObject *item in array) {
////                PushMsg *pushMsg = [[PushMsg alloc] initWithDictionary:item];
//                Notice *notice = [[Notice alloc] initWithString:[item objectForKey:@"extra"]];
//                notice.aps = [ApsInfo apsInfoWithAlert:[item objectForKey:@"content"] badge:0 sound:nil];
//                notice.objectId = item.objectId;
//                [self saveNotice:notice];
//                [item setObject:[NSNumber numberWithInteger:[[NSNumber numberWithInteger:YES] integerValue]] forKey:@"isRead"];
//                [item updateInBackground];
//            }
//            
//        }
//    }];
//    
//    
//}

- (void)readLeagueNoticeListFinished:(void (^)(NSArray *noticeList))aFinishBlock
{
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSString *execute = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d AND %@!=%ld ORDER BY %@ DESC", kTableNotice, gNoticeColumnsName[NoticeColumnSubtype], 12, gNoticeColumnsName[NoticeColumnStatus], (long)NoticeStatusDisposed, gNoticeColumnsName[NoticeColumnTime]];
        
        NSMutableArray *noticeList = [[NSMutableArray alloc] init];
        FMResultSet *s = [db executeQuery:execute];
        int i = 0;
        while ([s next] && i < 50)
        {
            NSDictionary *dic = [self _convertNoticeResult:s];
            Notice *nti = [[Notice alloc] initWithDictionary:dic];
            [noticeList addObject:nti];
            i ++;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([noticeList count] > 0) {
                [self markNoticesRead:noticeList];
            }
            if (aFinishBlock)
            {
                aFinishBlock(noticeList);
            }
            
        });
    }];
}

#pragma mark - 数据库基础操作

//更新数据库
- (BOOL)_excuteAddColumnStatementToDB:(FMDatabase *)aDB column:(NSString *)aColumn type:(NSString *)aType ifNotExistInTable:(NSString *)aTable
{
    NSString *executeString = [NSString stringWithFormat:@"alter table %@ add %@ %@", aTable, aColumn, aType];
    BOOL isSuccess = [aDB executeUpdate:executeString];
    return isSuccess;
}


// 查询是否存在该条记录
- (FMResultSet *)_excuteQueryExistToDB:(FMDatabase *)aDB column:(NSString *)aColumn value:(NSString *)aValue atTable:(NSString *)aTable
{
    NSString *condition = [NSString stringWithFormat:@"%@ = %@", aColumn, aValue];
    return [self _excuteQueryExistToDB:aDB contidtion:condition atTable:aTable];
}

// 查询是否存在该条记录
- (FMResultSet *)_excuteQueryExistToDB:(FMDatabase *)aDB contidtion:(NSString *)aCondition atTable:(NSString *)aTable
{
    NSString *executeString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",aTable, aCondition];
    //    DDLogDebug(@"查询语句 %@", executeString);
    FMResultSet *result = [aDB executeQuery:executeString];
    return result;
}

// 添加语句
- (BOOL)_excuteInsertStatementToDB:(FMDatabase *)aDB fromDic:(NSDictionary *)aDic atTable:(NSString *)aTable
{
    NSMutableString *parma = [[NSMutableString alloc] init];
    NSMutableString *values = [[NSMutableString alloc] init];
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
    int i = 0;
    NSArray *keys = [aDic allKeys];
    for (NSString *key in keys)
    {
        id object = [aDic objectForKey:key];
        [parma appendFormat:@"%@", key];
        [values appendFormat:@"?"];
        if (++i < keys.count)
        {
            [parma appendString:@", "];
            [values appendString:@", "];
        }
        [arguments addObject:object];
    }
    NSString *executeString = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",aTable, parma, values];
    //    DDLogDebug(@"插入语句 %@", executeString);
    
    BOOL isSuccess = [aDB executeUpdate:executeString withArgumentsInArray:arguments];
    return isSuccess;
}

// 更新语句
- (BOOL)_excuteUpdateStatementToDB:(FMDatabase *)aDB fromDic:(NSDictionary *)aDic condition:(NSString *)aCondition atTable:(NSString *)aTable
{
    NSMutableString *parma = [[NSMutableString alloc] init];
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
    int i = 0;
    NSArray *keys = [aDic allKeys];
    for (NSString *key in keys)
    {
        id object = [aDic objectForKey:key];
        [parma appendFormat:@"%@ = ?", key];
        [arguments addObject:object];
        if (++i < keys.count)
        {
            [parma appendString:@", "];
        }
    }
    NSString *executeString;
    if (aCondition.length > 0) {
        executeString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",aTable, parma, aCondition];
    }else
    {
        executeString = [NSString stringWithFormat:@"UPDATE %@ SET %@",aTable, parma];
    }
    
    BDLog(@"executeString %@",executeString);
    
    BOOL isSuccess = [aDB executeUpdate:executeString withArgumentsInArray:arguments];

    return isSuccess;
}


// 更新语句
//- (BOOL)_excuteUpdateStatementToDB:(FMDatabase *)aDB fromDic:(NSDictionary *)aDic column:(NSString *)aColumn value:(NSString *)aValue atTable:(NSString *)aTable
//{
//    NSString *condition = [NSString stringWithFormat:@"%@ = %@", aColumn, aValue];
//    return [self _excuteUpdateStatementToDB:aDB fromDic:aDic condition:condition atTable:aTable];
//}

- (BOOL)_excuteDeleteToDB:(FMDatabase *)aDB condition:(NSString *)aConditon atTable:(NSString *)aTable
{
    NSString *executeString = [NSString stringWithFormat:@"delete from %@ where %@", aTable, aConditon];
    BOOL isSuccess = [aDB executeUpdate:executeString];
    return isSuccess;
    
}

- (BOOL)_excuteDeleteToDB:(FMDatabase *)aDB column:(NSString *)aColumn value:(NSString *)aValue atTable:(NSString *)aTable
{
    NSString *condition = [NSString stringWithFormat:@"%@ = %@", aColumn, aValue];
    return [self _excuteDeleteToDB:aDB condition:condition atTable:aTable];
}

@end
