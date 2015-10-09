//
//  TeamEngine.m
//  SportsContact
//
//  Created by Nero on 8/7/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//


#import "TeamEngine.h"
#import "FCFileManager.h"
#import "Util.h"
#import "DateUtil.h"

@implementation TeamEngine


//获取用户加入的球队
+ (void)getTeamsWithUser:(BmobUser *)user block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery orderByDescending:@"updateAt"];
    [bquery whereKey:@"footballer" equalTo:user];
    [bquery includeKey:@"captain,footballer"];
    
    bquery.limit=1000;

//    [bquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error)
//        {
//            NSMutableArray *result = [NSMutableArray array];
//            for (id obj in array) {
//                [result addObject:[[Team alloc] initWithDictionary:obj]];
//            }
//            engineBlock(result, nil);
//            
//        }else
//        {
//            engineBlock(nil, error);
//        }
//
//    }];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array) {
                [result addObject:[[Team alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }

    }];
    
}

+(void)getTeamsObjectIdWith:(BmobUser *)user block:(void (^)(id, NSError *))engineBlock{
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery orderByDescending:@"updateAt"];
    [bquery whereKey:@"footballer" equalTo:user];
    //    [bquery includeKey:@"captain,footballer"];
    
    bquery.limit=1000;
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error) {
            NSMutableArray *result = [NSMutableArray array];
            for (BmobObject *obj in array) {
                [result addObject:obj.objectId];
            }
            if (engineBlock) {
                engineBlock(result,nil);
            }
        }else{
            if (engineBlock) {
                engineBlock(nil,error);
            }
        }
        
        
    }];
}

 // 获取用户加入的全部球队
+ (void)getJoinedTeamsWithUserId:(NSString *)userId block:(void (^)(id, NSError *))engineBlock
{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery orderByDescending:@"updatedAt"];
    [bquery includeKey:@"captain,footballer"];

    bquery.limit=1000;

    [bquery whereKey:@"footballer" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array) {
                [result addObject:[[Team alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }
        
        
    }];

    
    
    
}


+ (void)getTeamMembersWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *bquery = [BmobQuery queryForUser];
    [bquery orderByDescending:@"nickname"];
    bquery.limit=1000;
    [bquery whereObjectKey:@"footballer" relatedTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         if (!error)
         {
             NSMutableArray *result = [NSMutableArray array];
             for (id obj in array) {
                 [result addObject:[[UserInfo alloc] initWithDictionary:obj]];
             }
             engineBlock(result, nil);
         }else
         {
             engineBlock(nil, error);
         }
     }];
}

//+ (void)getTeamMembersWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *))engineBlock
//{
//    BmobQuery *bquery = [BmobQuery queryForUser];
//    [bquery orderByDescending:@"nickname"];
//    [bquery whereObjectKey:@"footballer" relatedTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId]];
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
//     {
//         if (!error)
//         {
//             NSMutableArray *result = [NSMutableArray array];
//             for (id obj in array) {
//                 [result addObject:[[UserInfo alloc] initWithDictionary:obj]];
//             }
//             engineBlock(result, nil);
//         }else
//         {
//             engineBlock(nil, error);
//         }
//     }];
//}

//切换球队
+ (void)getSwitchTeamsWithTeamId:(NSString *)teamId  UserId:(NSString *)userId block:(void (^)(id, NSError *))engineBlock
{
    
    //获取user加入的2个球队
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery includeKey:@"captain,footballer"];
    [bquery orderByDescending:@"updatedAt"];
    [bquery whereKey:@"footballer" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            
            for (id obj in array) {
                
//                [result addObject:[[Team alloc] initWithDictionary:obj]];
                
                Team *team=obj;
                if ([teamId isEqualToString:team.objectId])
                {
                    
                }
                else
                {
                    [result addObject:[[Team alloc] initWithDictionary:obj]];
                }
                
                
            }
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }
        
        
    }];

    
    
    
}


//退出球队

+ (void)getQuitTeamsWithTeamId:(NSString *)teamId  UserId:(NSString *)userId block:(void (^)(id, NSError *))engineBlock
{
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId];
    
    BmobRelation *relation = [[BmobRelation alloc] init];
    
    //relation要移除id为27bb999834的用户
    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    
    //obj 更新关联关系到likes列中
    [obj addRelation:relation forKey:@"footballer"];
    
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        
        if (!error)
        {
            engineBlock(nil, nil);
            
        }else
        {
            engineBlock(nil, error);
        }

        
        
    }];

    

    
}


/**
 *  删除球队
 *
 *  @param user 当前用户
 */
+ (void)getDeleteTeamsWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *))engineBlock
{
    
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    bquery.limit = 1000;//上限1000
    [bquery getObjectInBackgroundWithId:teamId block:^(BmobObject *object, NSError *error){
        
        if (error) {
            //进行错误处理
            
            
            engineBlock(nil, error);

        }
        else{
            
            
            if (object)
            {
                //异步删除object
                
                [object deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                    
                    if (isSuccessful)
                    {
                        engineBlock(nil, nil);
                    }
                    else
                    {
                        engineBlock(nil, error);
                    }
                    
                }];
                
            }
            
            
        }
    }];

    
    
}






//搜索球队用户名
+ (void)getSearchTeamWithTeamname:(NSString *)teamname block:(void (^)(id, NSError *)) engineBlock
{
    
    BmobQuery   *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery includeKey:@"captain,footballer"];

    [bquery whereKey:@"name" equalTo:teamname];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array) {
                [result addObject:[[Team alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }
        
    }];

    
    
    
}


//球队模糊搜索
+ (void)getFuzzySearchTeamWithTeamname:(NSString *)teamname block:(void (^)(id, NSError *)) engineBlock
{
    
    BmobQuery   *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery includeKey:@"captain,footballer"];
    
    bquery.limit = 1000;//上限1000

    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
//            NSMutableArray *result = [NSMutableArray array];
//            for (id obj in array) {
//                [result addObject:[[Team alloc] initWithDictionary:obj]];
//            }
            
            
            
            
            
            
            //模糊搜索，包含字段
            NSMutableArray *result = [NSMutableArray array];
            
            
            for (int i=0; i<[array count]; i++)
            {
                
                
                Team *team=[[Team alloc] initWithDictionary:[array objectAtIndex:i]];
                
                
                BDLog(@"*********%@",team.name);
                
                NSRange range = [team.name rangeOfString:teamname];
                
                if (range.location!=NSNotFound)
                {
                    //                    BDLog(@"Yes");
                    
                    [result addObject:team];
                    
                }else {
                    
                    //                    BDLog(@"NO");
                    
                }
                
                
            }
            
            
            
            
            
            
            
            
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }
        
    }];

    
    
}






//查询单个球队数据
+ (void)getInfoWithTeamname:(NSString *)teamname block:(void (^)(id, NSError *)) engineBlock
{
    
    BmobQuery *query = [BmobQuery queryWithClassName:kTableTeam];
    [query includeKey:@"captain,footballer"];
    [query whereKey:@"name" equalTo:teamname];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            if (array && [array count] > 0)
            {
                BmobObject *object = [array firstObject];
                Team *dicUser = [[Team alloc] initWithDictionary:object];
                engineBlock(dicUser, nil);
            }else
            {
                error = [NSError errorWithDomain:ErrorUnkown code:-1 userInfo:@{NSLocalizedDescriptionKey : @"未知异常"}];
                engineBlock(nil, error);
            }
        }else
        {
            engineBlock(nil, error);
        }
    }];
}




//获取用户附近球队
+ (void)getNearbyTeamWithUserCity:(NSString *)cityCode block:(void (^)(id, NSError *)) engineBlock
{
    
    //获取Team全部球队信息
//    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
//    
//    [bquery orderByDescending:@"updatedAt"];
//    
//    [bquery whereKeyExists:@"city"];//city有值
//    
//    [bquery includeKey:@"captain,footballer"];

    NSString *city = cityCode;
    if ([city length] >= 6) {
        city = [NSString stringWithFormat:@"%@00", [city substringToIndex:4]];
    }
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    
    bquery.limit=10000;
    
//    NSArray *array =  @[@{@"city":@{@"$ne":@""}},@{@"city":@{@"$exists":@1}}];
//    
//    [bquery addTheConstraintByAndOperationWithArray:array];
    [bquery whereKey:@"city" equalTo:city];
    [bquery orderByDescending:@"updatedAt"];

    [bquery includeKey:@"captain,footballer"];

    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        if (!error)
        {
            
            NSMutableArray *result = [NSMutableArray array];
            
            for (id obj in array)
            {
                Team *team=[[Team alloc] initWithDictionary:obj];
                
                BDLog(@"************%@*************%@",[cityCode substringWithRange:NSMakeRange(0,4)],[team.city substringWithRange:NSMakeRange(0,4)]);
                
                if ([[cityCode substringWithRange:NSMakeRange(0,4)] isEqualToString:[team.city substringWithRange:NSMakeRange(0,4)]])
                {
                    
                    [result addObject:[[Team alloc] initWithDictionary:obj]];
                    
                }
                
                
            }
            engineBlock(result, nil);
            
            
        }else
        {
            engineBlock(nil, error);
        }

        
        
        
        
        
    }];

    
    
    
}




//搜得到球队总人数
+ (void)getTeamMenberCountWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *)) engineBlock
{
    
    //获取球队的全部人数
    BmobQuery *bquery = [BmobQuery queryForUser];
    [bquery orderByDescending:@"updatedAt"];
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId];
    [bquery whereObjectKey:@"footballer" relatedTo:obj];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array) {
                [result addObject:[[UserInfo alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);
            
        }else
        {
            engineBlock(nil, error);
        }
        
    }];
    
        
    
    
}






//  获取赛程
+ (void)getMatchWithTeamId:(NSString *)aTeamId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *query = [BmobQuery queryWithClassName:kTableTournament];
    [query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [query orderByAscending:@"start_time"];
    
//        [query whereKey:@"end_time" greaterThanOrEqualTo:[NSDate date]];
    query.limit = 1000;//上限1000
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array) {
                
                [result addObject:[[Tournament alloc] initWithDictionary:obj]];
                
            }
            engineBlock(result, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}






//获取主场的全部比赛
+ (void)getAllHomeTouramentWithTeamId:(NSString *)aTeamId limit:(int)limit block:(void (^)(id, NSError *))engineBlock
{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain,group"];
    [bquery whereKeyExists:@"start_time"];//要求是有时间存在的，没有时间不显示
    [bquery orderByDescending:@"start_time"];

    bquery.limit=limit;
    
    [bquery whereKey:@"home_court" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:aTeamId]];
    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error)
        {
            
            if ([array count]==0)
            {
                engineBlock(nil, nil);
                
            }
            else
            {
                
                //遍历数组，主场的全部tourament
                NSMutableArray *result = [NSMutableArray array];
                
                for (id obj in array)
                {
                    
                [result addObject:[[Tournament alloc] initWithDictionary:obj]];
                    
                }
                
                engineBlock(result, nil);
                
                
            }
        }else
        {
            engineBlock(nil, error);
        }

    }];
}



//获取客场的全部比赛
+ (void)getAllGusstTouramentWithTeamId:(NSString *)aTeamId limit:(int)limit block:(void (^)(id, NSError *))engineBlock
{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [bquery whereKeyExists:@"start_time"];//要求是有时间存在的，没有时间不显示
    [bquery orderByDescending:@"start_time"];
    
    bquery.limit=limit;
    
    [bquery whereKey:@"opponent" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:aTeamId]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        if (!error)
        {
            
            if ([array count]==0)
            {
                engineBlock(nil, nil);
                
            }
            else
            {
                //遍历数组，全部客场tourament
                NSMutableArray *result = [NSMutableArray array];
                
                for (id obj in array)
                {
                [result addObject:[[Tournament alloc] initWithDictionary:obj]];
                }
                
                engineBlock(result, nil);
                
                
            }
            
            
            
            
        }else
        {
            engineBlock(nil, error);
        }

    }];
    
}


+(void)getAllTouramentWithTeamId:(NSString *)aTeamId limit:(int)limit block:(void (^)(id, NSError *))engineBlock{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [bquery whereKeyExists:@"start_time"];//要求是有时间存在的，没有时间不显示
    [bquery orderByDescending:@"start_time"];
    bquery.limit=limit;
    NSDictionary *condiction1 = @{@"home_court":@{@"__type":@"Pointer",@"className":kTableTeam,@"objectId":aTeamId}};
    NSDictionary *condiction2 = @{@"opponent":@{@"__type":@"Pointer",@"className":kTableTeam,@"objectId":aTeamId}};;
    
    [bquery addTheConstraintByOrOperationWithArray:@[condiction1,condiction2]];
//    [bquery whereKey:@"opponent" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:aTeamId]];
    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        if (!error)
        {
            
            if ([array count]==0)
            {
                engineBlock(nil, nil);
                
            }
            else
            {
                //遍历数组，全部客场tourament
                NSMutableArray *result = [NSMutableArray array];
                
                for (id obj in array)
                {
                    [result addObject:[[Tournament alloc] initWithDictionary:obj]];
                }
                
                engineBlock(result, nil);
                
                
            }
            
            
            
            
        }else
        {
            engineBlock(nil, error);
        }
        
    }];
}



+(void)getLastestTouramentWithTeamId:(NSString *)aTeamId  block:(void (^)(id, NSError *))engineBlock{
    [[self class] getOneTouramentWithTeamId:aTeamId lastestGame:YES block:engineBlock];
}


+(void)getNearestTouramentWithTeamId:(NSString *)aTeamId  block:(void (^)(id, NSError *))engineBlock{
    [[self class] getOneTouramentWithTeamId:aTeamId lastestGame:NO block:engineBlock];
}


+(void)getOneTouramentWithTeamId:(NSString *)aTeamId lastestGame:(BOOL)last  block:(void (^)(id, NSError *))engineBlock{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain,group"];
    [bquery whereKeyExists:@"start_time"];//要求是有时间存在的，没有时间不显示
    
    if (last) {
        [bquery orderByDescending:@"start_time"];
        [bquery whereKey:@"start_time" lessThanOrEqualTo:[NSDate dateFromServer]];
    }else{
        NSDate *date = [NSDate dateFromServer];
        [bquery orderByAscending:@"start_time"];
        [bquery whereKey:@"start_time" greaterThanOrEqualTo:date];
//        NSLog(@"date  %@",date);
    }
    
    bquery.limit=1;
    
    NSDictionary *condiction1 = @{@"home_court":@{@"__type":@"Pointer",@"className":kTableTeam,@"objectId":aTeamId}};
    NSDictionary *condiction2 = @{@"opponent":@{@"__type":@"Pointer",@"className":kTableTeam,@"objectId":aTeamId}};;
    
    [bquery addTheConstraintByOrOperationWithArray:@[condiction1,condiction2]];
    //    [bquery whereKey:@"home_court" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:aTeamId]];
    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        
        if (!error)
        {
            
            if ([array count]==0)
            {
                engineBlock(nil, nil);
                
            }
            else
            {
//                for (BmobObject ) {
//                    <#statements#>
//                }
                
                //遍历数组，主场的全部tourament
                NSMutableArray *result = [NSMutableArray array];
                
                for (id obj in array)
                {
                    
                    [result addObject:[[Tournament alloc] initWithDictionary:obj]];
                    
                }
                
                engineBlock(result, nil);
                
                
            }
        }else
        {
            engineBlock(nil, error);
        }
        
    }];
}










+ (void)getInfoWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *)) engineBlock
{
    

    
    BmobQuery *query = [BmobQuery queryWithClassName:kTableTeam];
    [query includeKey:@"captain,footballer"];
    query.limit = 1000;//上限1000
    [query getObjectInBackgroundWithId:teamId block:^(BmobObject *object, NSError *error) {
        if (!error)
        {
            Team *result = [[Team alloc] initWithDictionary:object];
            engineBlock(result, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

//更改球队资料
+ (void)updateTeamInfoWithteamId:(NSString  *)teamId avatarImage:(UIImage *)avatar changes:(NSDictionary *)changes  block:(void (^)(id, NSError *)) engineBlock
{
    
    BDLog(@"changes===========%@",changes);
    
    BmobQuery   *bquery = [BmobQuery queryWithClassName:kTableTeam];
    
    [bquery getObjectInBackgroundWithId:teamId block:^(BmobObject *object,NSError *error){
        
        //没有返回错误
        if (!error) {
            //对象存在
            if (object) {
                
                
                for (NSString *key in [changes allKeys])
                {
                    
                    if ([key isEqualToString:@"captain"])
                    {
                        
                    }
                    else
                    {
                        [object setObject:[changes objectForKey:key] forKey:key];
                    }
                }
                
                
                //异步更新数据
                [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    
                    if (!isSuccessful)
                    {
                        engineBlock(nil,error);
                        return ;
                    }
                    
                    if (avatar)
                    {
                        NSString *filename = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]];
                        NSString *filepath = [FCFileManager pathForCachesDirectoryWithPath:filename];
                        NSData *avatarData = UIImagePNGRepresentation(avatar);
                        [avatarData writeToFile:filepath atomically:YES];
                        BmobFile *avatarFile = [[BmobFile alloc] initWithFilePath:filepath];
                        
                        [avatarFile saveInBackground:^(BOOL isSuccessful, NSError *error)
                         {
                             if (isSuccessful)
                             {
                                 [object setObject:avatarFile  forKey:@"avator"];
                                 [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                                  {
                                      if (isSuccessful) {
                                          engineBlock(nil, nil);
                                      }else
                                      {
                                          engineBlock(nil, error);
                                      }
                                  }];
                             }else
                             {
                                 //进行处理
                                 engineBlock(nil,error);
                             }
                         }];
                    }else
                    {
                        engineBlock(nil, nil);
                    }
                }];
                
                
                
                
                
                
                
            }
        }else{
            //进行错误处理
        }
    }];
    
    
    
    
    
    
    
    
    
    
}



//更换队长
+ (void)changeCaptainWithteamId:(NSString *)teamId captainUserid:(NSString *)userId block:(void (^)(id, NSError *)) engineBlock;
{
    
    BmobQuery   *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery getObjectInBackgroundWithId:teamId block:^(BmobObject *object,NSError *error){
        
        if (!error) {
            
            if (object) {
                
                //Pointer属性
                [object setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId] forKey:@"captain"];
                
                [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error){
                
                    
                    if (isSuccessful) {
                        engineBlock(nil, nil);
                    }else
                    {
                        engineBlock(nil, error);
                    }

                
                
                }];
                
                
            }
        }else{
            //进行错误处理
        }
    }];
    
    
    

    
    
}


// 获取球队阵容信息
+ (void)getLineupWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableLineup];
    [bquery whereKey:@"team" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId]];
    [bquery includeKey:@"team,goalkeeper,back,striker,forward"];
    [bquery orderByDescending:@"updatedAt"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         if (error)
         {
             //球队阵容不存在
             engineBlock(nil, error);
         }else
         {
             if ([array count] > 0)
             {
//                 engineBlock([[Lineup alloc] initWithDictionary:[array firstObject]], nil);
                 __block NSInteger requestCount = 3;
                 NSMutableArray *errs = [NSMutableArray arrayWithCapacity:0];
                 BmobObject *lineupObj = [array firstObject];
                 Lineup *lineup = [[Lineup alloc] initWithDictionary:lineupObj];
                 NSLog(@"objectId %@",lineup.objectId);
                 BmobQuery *backerQuery = [BmobUser query];
                 [backerQuery whereObjectKey:@"back" relatedTo:lineupObj];
                 [backerQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *err)
                 {
                     requestCount --;
                     if (err) {
                         [errs addObject:err];
                     }else
                     {
                         NSMutableArray *users = [NSMutableArray arrayWithCapacity:0];
                         for (id obj in array) {
                             [users addObject:[[UserInfo alloc] initWithDictionary:obj]];
                         }
                         lineup.back = (id)users;
                     }
                     
                     if (requestCount <=0)
                     {
                         if ([errs count] > 0) {
                             engineBlock(nil, [errs lastObject]);
                         }else
                         {
                            engineBlock(lineup, nil);
                         }
                     }
                 }];
                 BmobQuery *strikerQuery = [BmobUser query];
                 [strikerQuery whereObjectKey:@"striker" relatedTo:lineupObj];
                 [strikerQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *err)
                 {
                     requestCount --;
                     if (err) {
                         [errs addObject:err];
                     }else
                     {
                         NSMutableArray *users = [NSMutableArray arrayWithCapacity:0];
                         for (id obj in array) {
                             [users addObject:[[UserInfo alloc] initWithDictionary:obj]];
                         }
                         lineup.striker = (id)users;
                     }
                     if (requestCount <=0)
                     {
                         if ([errs count] > 0) {
                             engineBlock(nil, [errs lastObject]);
                         }else
                         {
                             engineBlock(lineup, nil);
                         }
                     }
                 }];
                 
                 BmobQuery *forwardQuery = [BmobUser query];
                 [forwardQuery whereObjectKey:@"forward" relatedTo:lineupObj];
                 [forwardQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *err)
                  {
                      requestCount --;
                      if (err) {
                          [errs addObject:err];
                      }else
                      {
                          NSMutableArray *users = [NSMutableArray arrayWithCapacity:0];
                          for (id obj in array) {
                              [users addObject:[[UserInfo alloc] initWithDictionary:obj]];
                          }
                          lineup.forward = (id)users;
                      }
                      if (requestCount <=0)
                      {
                          if ([errs count] > 0) {
                              engineBlock(nil, [errs lastObject]);
                          }else
                          {
                              engineBlock(lineup, nil);
                          }
                      }
                  }];
                 
             }else
             {
                 engineBlock(nil, nil);
             }
         }
     }];
}


//创建球队阵容
+ (void)createLineupWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *))engineBlock
{
    
    BmobObject *obj =[BmobObject objectWithClassName:kTableLineup];
    
    [obj setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId] forKey:@"team"];

    [obj saveInBackgroundWithResultBlock:^ (BOOL isSuccessful, NSError *error){
        
        
        
        if (error)
        {
            engineBlock(nil, error);

        }
        else
        {
            
            engineBlock(nil, nil);

        }

    
    }];
    
    

    
    
    
    
}


//更新球队阵容
+ (void)upDateLineupWithTeamId:(NSString *)teamId block:(void (^)(id, NSError *))engineBlock
{
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableLineup objectId:teamId];
    
    [obj setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId] forKey:@"team"];
    
    [obj setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"fwXuDDDP"] forKey:@"goalkeeper"];
    
    
    BmobRelation *relation = [[BmobRelation alloc] init];
    
    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"itNNZ00U"]];
    [obj addRelation:relation forKey:@"back"];
    
    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"itNNZ00U"]];
    [obj addRelation:relation forKey:@"striker"];
    
    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"URR5XKKS"]];
    [obj addRelation:relation forKey:@"forward"];
    
    //异步更新obj的数据
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
         BDLog(@"error %@",[error description]);
         
     }];


    
}



//获取个人比赛得分
+ (void)getPlayerScoreWithUserID:(NSString *)userId block:(void (^)(id, NSError *))engineBlock
{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTablePlayerScore];

    [bquery orderByDescending:@"updatedAt"];
    
    [bquery includeKey:@"league,competition,team,player"];


    [bquery whereKey:@"player" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        
        if (!error)
        {
            
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array)
            {
                [result addObject:[[PlayerScore alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);

            
        }
        else
        {
            engineBlock(nil, error);

        }
        
        
        
        
    }];

    
    
    
}




+(void)getLeagueGamesNumberWithUserID:(NSString *)userId
                                block:(void(^)(NSInteger count,NSError *error))block{
    BmobQuery   *query = [BmobQuery queryWithClassName:kTableLeague];
    BmobUser *user = [BmobUser objectWithoutDatatWithClassName:nil objectId:userId];
    [query whereKey:@"master" equalTo:user];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (block) {
            block(number,error);
        }
    }];
}








@end
