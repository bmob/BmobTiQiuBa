//
//  LeagueEngine.m
//  SportsContact
//
//  Created by Nero on 8/14/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "LeagueEngine.h"
#import "Util.h"
#import "DateUtil.h"



@implementation LeagueEngine





//获取用户加入的球队
+ (void)getTeamsWithUser:(BmobUser *)user block:(void (^)(id, NSError *))engineBlock
{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery orderByDescending:@"updateAt"];
    [bquery whereObjectKey:@"team" relatedTo:user];
    //    [bquery includeKey:@"friends"];
    [bquery includeKey:@"captain,footballer"];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array)
            {
                [result addObject:[[Team alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }
        
    }];

}

//获取最近联赛的信息
+(void)getLastLeagueMatchWithTeamId:(NSString *)aTeamId block:(void (^)(id, NSError *))engineBlock{

    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [bquery whereKeyExists:@"start_time"];
    [bquery orderByDescending:@"start_time"];//时间降序
    bquery.limit=10;
    NSDictionary *condiction1 = @{@"league":@{@"$ne":@""}};
    NSDictionary *condiction2 = @{@"league":@{@"$exists":[NSNumber numberWithBool:YES]}};
    [bquery addTheConstraintByAndOperationWithArray:@[condiction1,condiction2]];
    
    NSDictionary *home_courtCondiction =@{@"home_court":@{@"__type":@"Pointer",@"className":kTableTeam,@"objectId":aTeamId}};
    NSDictionary *oppCondiction  =@{@"opponent":@{@"__type":@"Pointer",@"className":kTableTeam,@"objectId":aTeamId}};
    [bquery addTheConstraintByOrOperationWithArray:@[home_courtCondiction,oppCondiction]];
    
//    [bquery whereKey:@"home_court" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:aTeamId]];
    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            
            //按开始时间排序，取第一个，时间倒序，取最新的联赛
            if ([array count]==0)
            {
                engineBlock(nil, nil);
                
            }
            else
            {
                NSDate *serverDate=[NSDate dateFromServer];
                
                NSMutableArray *beforeArr = [NSMutableArray array];
                for (id obj in array)
                {
                    
                    //比较时间先后
                    
                    Tournament *tourament=[[Tournament alloc] initWithDictionary:obj];
                    
                    if ([tourament.start_time isEarlierThanDate:serverDate])
                    {
                        
                        BDLog(@"*********%@",tourament.start_time);
                        //未开始的比赛
                        [beforeArr addObject:[[Tournament alloc] initWithDictionary:obj]];
                    }
                    
                    
                }
                
                
                
                
                
                
                NSMutableArray *result = [NSMutableArray array];
                
                @try {
                    [result addObject:[beforeArr firstObject]];
                }
                @catch (NSException *exception) {
                    BDLog(@"exception %@",exception);
                }
                @finally {
                    
                }
                
                //                if (beforeArr.count > 0) {
                //                    [result addObject:[beforeArr firstObject]];
                //                }
                
                
                
                if ([result count]!=0)
                {
                    engineBlock(result, nil);
                }
                else
                {
                    engineBlock(nil, nil);
                }
                
                
            }
            
            
        }else
        {
            engineBlock(nil, error);
        }
        
        
        
        
        
        
        
    }];


}

;

//  获取主场的最后一场比赛
+ (void)getHomeMatchWithTeamId:(NSString *)aTeamId block:(void (^)(id, NSError *))engineBlock;
{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [bquery whereKeyExists:@"start_time"];
    [bquery orderByDescending:@"start_time"];//时间降序
    bquery.limit=1000;
//    NSDictionary *condiction1 = @{@"league":@{@"$ne":@""}};
//    NSDictionary *condiction2 = @{@"league":@{@"$exists":[NSNumber numberWithBool:YES]}};
//    [bquery addTheConstraintByAndOperationWithArray:@[condiction1,condiction2]];
    
    [bquery whereKey:@"home_court" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:aTeamId]];
    

    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        

        
        if (!error)
        {
            
            //按开始时间排序，取第一个，时间倒序，取最新的联赛
            if ([array count]==0)
            {
                engineBlock(nil, nil);

            }
            else
            {
                
                
                NSDate *serverDate=[NSDate dateFromServer];
                
                

                
                
                NSMutableArray *beforeArr = [NSMutableArray array];
                for (id obj in array)
                {
                    
                    //比较时间先后
                    
                    Tournament *tourament=[[Tournament alloc] initWithDictionary:obj];
                    
                    if ([tourament.start_time isEarlierThanDate:serverDate])
                    {
                        
                        BDLog(@"*********%@",tourament.start_time);
                        //未开始的比赛
                        [beforeArr addObject:[[Tournament alloc] initWithDictionary:obj]];
                    }
                    
                    
                }

                
                

                
                
                NSMutableArray *result = [NSMutableArray array];
                
                @try {
                    [result addObject:[beforeArr firstObject]];
                }
                @catch (NSException *exception) {
                    BDLog(@"exception %@",exception);
                }
                @finally {
                    
                }
                
//                if (beforeArr.count > 0) {
//                    [result addObject:[beforeArr firstObject]];
//                }
                
                
                
                if ([result count]!=0)
                {
                    engineBlock(result, nil);
                }
                else
                {
                    engineBlock(nil, nil);
                }

                
            }

            
        }else
        {
            engineBlock(nil, error);
        }
        

        

        
        
        
    }];
}

//获取客场的最后一场比赛
+ (void)getGuestMatchWithTeamId:(NSString *)aTeamId block:(void (^)(id, NSError *))engineBlock;
{
   
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [bquery whereKeyExists:@"start_time"];
    [bquery orderByDescending:@"start_time"];
    bquery.limit=1000;
    [bquery whereKey:@"opponent" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:aTeamId]];
    
//    NSDictionary *condiction1 = @{@"league":@{@"$ne":@""}};
//    NSDictionary *condiction2 = @{@"league":@{@"$exists":[NSNumber numberWithBool:YES]}};
//    [bquery addTheConstraintByAndOperationWithArray:@[condiction1,condiction2]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        if (!error)
        {
            
            //按开始时间排序，取第一个，时间倒序，取最新的联赛
            if ([array count]==0)
            {
                engineBlock(nil, nil);

            }
            else
            {
                
                
                
                NSDate *serverDate=[NSDate dateFromServer];
                
                
                
                NSMutableArray *beforeArr = [NSMutableArray array];
                for (id obj in array)
                {
                    
                    //比较时间先后
                    
                    Tournament *tourament=[[Tournament alloc] initWithDictionary:obj];
                    if ([tourament.start_time isEarlierThanDate:serverDate])
                    {
                        //未开始的比赛
                        [beforeArr addObject:[[Tournament alloc] initWithDictionary:obj]];
                    }
                    
                    
                }
                NSMutableArray *result = [NSMutableArray array];
                @try {
                    [result addObject:[beforeArr firstObject]];
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                
                
                
                
                
                if ([result count]!=0)
                {
                    engineBlock(result, nil);
                }
                else
                {
                    engineBlock(nil, nil);
                }

                
            }
            
            
            
            
        }else
        {
            engineBlock(nil, error);
        }

        
        
        
        
        
    }];

    
    
    
}

    
    
    
    
    
    
    
    
    
    
    
    
    
    




//获取赛事属于的联赛
+ (void)getLeagueWithTournamentId:(NSString *)tournamentId block:(void (^)(id, NSError *))engineBlock
{
    
    
    BmobQuery *query = [BmobQuery queryWithClassName:kTableLeague];
    [query orderByAscending:@"start_time"];
    
    [query getObjectInBackgroundWithId:tournamentId block:^(BmobObject *object,NSError *error){
        
        
        if (!error)
        {
            engineBlock(object, nil);

        }
        else
        {
            engineBlock(nil, error);
            
        }
        
    }];

    
    
    
    
}




//获取附近的联赛
+ (void)getNearbyLeagueWithCitycode:(NSString *)cityCode block:(void (^)(id, NSError *))engineBlock
{
    
    //获取tourament全部联赛信息
//    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableLeague];
//    
//    [bquery orderByDescending:@"updatedAt"];
//    
//    [bquery whereKeyExists:@"city"];//city有值
//    
    
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableLeague];
    
    bquery.limit=1000;
    
    NSArray *array =  @[@{@"city":@{@"$ne":@""}},@{@"city":@{@"$exists":@1}}];
    
    [bquery addTheConstraintByAndOperationWithArray:array];
    
    [bquery orderByDescending:@"updatedAt"];

    
    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        if (!error)
        {
            
            NSMutableArray *result = [NSMutableArray array];
            
            for (id obj in array)
            {
                League *league=[[League alloc] initWithDictionary:obj];
                
//                BDLog(@"************%@*************%@",cityCode,league.city);
//
//                
//                BDLog(@"************%@*************%@",[cityCode substringWithRange:NSMakeRange(0,4)],[league.city substringWithRange:NSMakeRange(0,4)]);
                
                if ([cityCode length] > 4 && [league.city length] > 4 && [[cityCode substringWithRange:NSMakeRange(0,4)] isEqualToString:[league.city substringWithRange:NSMakeRange(0,4)]])
                {
                    [result addObject:league];
                }
                
                
            }
            engineBlock(result, nil);
            
            
        }else
        {
            engineBlock(nil, error);
        }
        
        
        
        
        
        
    }];
    
    
    
    
}





//根据联赛名字，获取联赛信息
+ (void)getSearchWithTouramentName:(NSString *)touramentName block:(void (^)(id, NSError *))engineBlock
{
    
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableLeague];
    [bquery orderByDescending:@"updateAt"];
    
    bquery.limit = 1000;//上限1000

    
//    [bquery whereKey:@"name" equalTo:touramentName];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        //模糊搜索
        
        if (!error)
        {
            

            
            //模糊搜索，包含字段
            NSMutableArray *result = [NSMutableArray array];
            
            
            for (int i=0; i<[array count]; i++)
            {
                
                
                League *league=[[League alloc] initWithDictionary:[array objectAtIndex:i]];
                
                
                BDLog(@"*********%@",league.name);
                
                NSRange range = [league.name rangeOfString:touramentName];
                
                if (range.location!=NSNotFound)
                {
                    //                    BDLog(@"Yes");
                    
                    [result addObject:league];
                    
                }else {
                    
                    //                    BDLog(@"NO");
                    
                }
                
                
            }

            
            
            
            engineBlock(result, nil);
            
            
        }
        else
        {
            engineBlock(nil, error);
            
        }
        
        
        
    }];

    

    
    
    
    
    
}




//获得某联赛各球队积分表
+ (void)getTeamscoreWithLeagueId:(NSString *)leagueId block:(void (^)(id, NSError *))engineBlock
{
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableLeagueScoreStat];

    [bquery orderByDescending:@"points"];
    [bquery orderByDescending:@"goalDifference"];
    [bquery includeKey:@"league,team"];
    
    bquery.limit=10000;

    [bquery whereKey:@"league" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        if ([array count]!=0)
        {
            
            if (!error)
            {
                NSMutableArray *result = [NSMutableArray array];
                for (id obj in array)
                {
                    [result addObject:[[LeagueScoreStat alloc] initWithDictionary:obj]];
                }
//                engineBlock(result, nil);
                
                [[self class] getGroupWithLeagueId:leagueId
                                  leagueScoreStats:result
                                             block:engineBlock];
                
            }
            else
            {
                
                engineBlock(nil, error);
                
            }
        }
        else
        {
            
            engineBlock(nil, nil);

        }
    }];
}

//返回该联赛的分组信息，包括objectId和name
+(void)getGroupWithLeagueId:(NSString *)leagueId
              leagueScoreStats:(NSMutableArray *)result
                         block:(void (^)(id, NSError *))engineBlock{
    
    BmobQuery *query = [BmobQuery queryWithClassName:kTableGroup];
    [query whereKey:@"league" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId]];
    [query selectKeys:@[@"objectId",@"name"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        [[self class] getGroupWithLeagueScoreStats:result
                                        groupArray:array
                                             block:engineBlock];
    }];
    
}


+(void)getGroupWithLeagueScoreStats:(NSMutableArray *)result
                         groupArray:(NSArray *)groupArray
                              block:(void (^)(id, NSError *))engineBlock{
    [[self class] getTeamGroupIdWithGroupIndex:0
                                    groupArray:groupArray
                              leagueScoreStats:result
                                         block:engineBlock];
    
}

//获取某个球队的分组
+(void)getTeamGroupIdWithGroupIndex:(int)groupIndex
                         groupArray:(NSArray *)groupArray
                   leagueScoreStats:(NSMutableArray *)result
                              block:(void (^)(id, NSError *))engineBlock{
    BmobObject *groupObj = [groupArray objectAtIndex:groupIndex];
    BmobQuery *query1 = [BmobQuery queryWithClassName:kTableTeam];
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableGroup objectId:groupObj.objectId];
    [query1 selectKeys:@[@"objectId"]];
    [query1 whereObjectKey:@"teams" relatedTo:obj];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (array && array.count > 0) {
            NSMutableArray *objIdArray = [NSMutableArray array];
            for (BmobObject *obj in array) {
                [objIdArray addObject:obj.objectId];
            }
            
            NSArray *resultCopy = [result copy];
            [resultCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([objIdArray containsObject:[[(LeagueScoreStat *)obj team]objectId]]) {
                    LeagueScoreStat *tmpLSS = [result objectAtIndex:idx];
                    tmpLSS.name = [groupObj objectForKey:@"name"];
                }
            }];
            
            if (groupIndex + 1 < groupArray.count) {
                [[self class] getTeamGroupIdWithGroupIndex:groupIndex + 1
                                                groupArray:groupArray
                                          leagueScoreStats:result
                                                     block:engineBlock];
            }else{
                if (engineBlock) {
                    engineBlock(result,nil);
                }
            }
            
            
        }else if(array.count == 0) {
            if (groupIndex + 1 < groupArray.count) {
                [[self class] getTeamGroupIdWithGroupIndex:groupIndex + 1
                                                groupArray:groupArray
                                          leagueScoreStats:result
                                                     block:engineBlock];
            }else{
                if (engineBlock) {
                    engineBlock(result,error);
                }
            }
        }
    }];
    
}

//获取联赛射手榜
+ (void)getPlayerscoreWithLeagueId:(NSString *)leagueId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTablePlayerScore];
//    [bquery orderByDescending:@"updatedAt"];
    [bquery orderByDescending:@"goals"];
    [bquery orderByDescending:@"assists"];
    [bquery includeKey:@"player,competition,team"];
    [bquery whereKey:@"goals" notEqualTo:@0];
    [bquery whereKey:@"league" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if ([array count]!=0){
            if (!error){
                NSMutableArray *result = [NSMutableArray array];
                for (id obj in array)
                {
                    [result addObject:[[PlayerScore alloc] initWithDictionary:obj]];
                }
                engineBlock(result, nil);
            }else{
                engineBlock(nil, error);
            }
        }else{
            engineBlock(nil, nil);
        }
    }];
}


//获取某联赛的全部球队比赛结果
+ (void)getLeagueResultWithLeagueId:(NSString *)leagueId block:(void (^)(id, NSError *))engineBlock
{
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    
    [bquery whereKeyExists:@"start_time"];//刚创建的比赛，还没有开始时间，就不显示在列表
    
    [bquery orderByDescending:@"start_time"];
    
    [bquery includeKey:@"league,home_court,home_court.captain,opponent,opponent.captain"];
    
    bquery.limit=1000;
    
    [bquery whereKey:@"league" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        

//        //获取服务器时间
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        //设置时区
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
//        //时间格式
//        [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
//        //调用获取服务器时间接口，返回的是时间戳
//        NSString  *timeString = [Bmob getServerTimestamp];
//        //时间戳转化成时间
//        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:[timeString intValue]];
//        
//        
//        //相应时区时间
//        NSTimeZone *zone = [NSTimeZone systemTimeZone];
//        NSInteger interval = [zone secondsFromGMTForDate:serverDate];
//        NSDate *localeDate = [serverDate  dateByAddingTimeInterval: interval];

        
        
        NSDate *localeDate=[NSDate dateFromServer];

        
        

        

        if ([array count]!=0)
        {
            
            if (!error)
            {
                NSMutableArray *result = [NSMutableArray array];
                for (id obj in array)
                {
                    
                    //比较时间先后

                    Tournament *tourament=[[Tournament alloc] initWithDictionary:obj];
                    
                    if ([tourament.start_time isEarlierThanDate:localeDate])
                    {
                        //已经结束的比赛
                        [result addObject:[[Tournament alloc] initWithDictionary:obj]];
                    }
                    
                    
                }
                engineBlock(result, nil);
                
                
                
            }
            else
            {
                
                engineBlock(nil, error);
                
            }
            
            
            
        }else{
            
            engineBlock(nil, nil);
            
        }
    }];
    
    
    
    
}

//#pragma mark -  time transform
//- (NSString *)formatDate
//{
//    return [self formatDateTimeWithPattern:@"yyyy-MM-dd"];
//}
//- (NSString *)formatDateTime
//{
//    return [self formatDateTimeWithPattern:@"yyyy-MM-dd HH:mm:ss"];
//}
//- (NSString *)formatDateTimeWithPattern:(NSString *)pattern
//{
//    static NSDateFormatter *formatter = nil;
//    if (!formatter) {
//        formatter = [[NSDateFormatter alloc] init];
//    }
//    formatter.dateFormat = pattern;
//    return [formatter stringFromDate:self];
//}
//- (NSDate *)formatDateTimeString
//{
//    return [self formatDateTimeStringWithPattern:@"yyyy-MM-dd HH:mm:ss"];
//}
//- (NSDate *)formatDateTimeStringWithPattern:(NSString *)pattern
//{
//    static NSDateFormatter *formatter = nil;
//    if (!formatter) {
//        formatter = [[NSDateFormatter alloc] init];
//        
//    }
//    formatter.dateFormat = pattern;
//    return [formatter dateFromString:self];
//}



//获取联赛赛程
+ (void)getLeagueScheduleWithLeagueId:(NSString *)leagueId block:(void (^)(id, NSError *))engineBlock
{
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    
    [bquery whereKeyExists:@"start_time"];//刚创建的比赛，还没有开始时间，就不显示在列表
    
    [bquery orderByDescending:@"start_time"];
    
    bquery.limit=1000;
    
    [bquery includeKey:@"league,home_court,home_court.captain,opponent,opponent.captain"];
    
    [bquery whereKey:@"league" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
//        //获取服务器时间
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        //设置时区
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
//        //时间格式
//        [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
//        //调用获取服务器时间接口，返回的是时间戳
//        NSString  *timeString = [Bmob getServerTimestamp];
//        //时间戳转化成时间
//        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:[timeString intValue]];
        
        
        
        NSDate *serverDate=[NSDate dateFromServer];

        
        if ([array count]!=0)
        {
            
            if (!error)
            {
                NSMutableArray *result = [NSMutableArray array];
                for (id obj in array)
                {
                    
                    //比较时间先后
                    
                    Tournament *tourament=[[Tournament alloc] initWithDictionary:obj];
                    
                    if ([tourament.start_time isLaterThanDate:serverDate])
                    {
                        //未开始的比赛
                        [result addObject:[[Tournament alloc] initWithDictionary:obj]];
                    }
                    
                    
                }
                engineBlock(result, nil);
                
                
                
            }
            else
            {
                
                engineBlock(nil, error);
                
            }
            
            
            
        }
        else
        {
            
            engineBlock(nil, nil);
            
        }
        
        
        
        
        
        
        
        
    }];
    
    
    
    
}




//各比赛的进球人员
+ (void)getFootballerGoalWithLeagueId:(NSString *)leagueId block:(void (^)(id, NSError *))engineBlock
{
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTablePlayerScore];
    
    [bquery orderByDescending:@"updatedAt"];
    
    [bquery whereKeyExists:@"league"];
    
    [bquery includeKey:@"player,competition,team"];
    
    [bquery whereKey:@"league" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        if ([array count]!=0)
        {
            
            if (!error)
            {
                NSMutableArray *result = [NSMutableArray array];
                for (id obj in array)
                {
                    PlayerScore *ps = [[PlayerScore alloc] initWithDictionary:obj];
                    [result addObject:ps];
                    
                    
                }
                engineBlock(result, nil);
                
                
                
            }
            else
            {
                
                engineBlock(nil, error);
                
            }
            
            
            
        }
        else
        {
            
            engineBlock(nil, nil);
            
        }
        
        
        
        
        
        
        
        
    }];
    
    
    
    
}









 //  获取某球队的参加的全部联赛
+ (void)getAllLeagueWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableLeague];
    [bquery orderByDescending:@"createdAt"];
    [bquery whereKey:@"teams" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId]];
    [bquery includeKey:@"master,teams,regTeams"];
    bquery.limit = 1000;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array) {
                
                [result addObject:[[League alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }
        
    }];
    

    
}

+(void)joinLeagueWithTeamId:(NSString *)teamId leagueId:(NSString *)leagueId block:(void(^)(BOOL isSuccessful,NSError *error))block{
    BmobObject *league = [BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId];
    
    BmobRelation *relation = [BmobRelation relation];
    BmobObject *team = [[BmobObject alloc] initWithClassName:kTableTeam];
    [relation addObject:team];
    [league setObject:relation forKey:@"regTeams"];
    [league updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (block) {
            block(isSuccessful,error);
        }
    }];
}



@end

















