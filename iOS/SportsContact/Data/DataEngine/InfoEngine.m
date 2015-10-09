//
//  InfoEngine.m
//  SportsContact
//
//  Created by bobo on 14-7-17.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "InfoEngine.h"
#import "FCFileManager.h"
#import "Util.h"
#import "DateUtil.h"

@implementation InfoEngine

+ (void)getInfoWithUserId:(NSString *)userId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *query = [BmobQuery queryForUser];
    [query getObjectInBackgroundWithId:userId block:^(BmobObject *object, NSError *error) {
        if (!error)
        {
            UserInfo *result = [[UserInfo alloc] initWithDictionary:object];
            engineBlock(result, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getInfoWithUsername:(NSString *)username block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *query = [BmobQuery queryForUser];
    [query includeKey:@"team"];
    if ([Util isValidOfPhoneNumber:username])//判断手机号合法
    {
        [query whereKey:@"username" equalTo:username];//用户名
    }
    else
    {
        [query whereKey:@"nickname" equalTo:username];//昵称
        
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            if (array && [array count] > 0)
            {
                BmobObject *object = [array firstObject];
                UserInfo *dicUser = [[UserInfo alloc] initWithDictionary:object];
                engineBlock(dicUser, nil);
            }else
            {
//                error = [NSError errorWithDomain:ErrorUnkown code:-1 userInfo:@{NSLocalizedDescriptionKey : @"未知异常"}];
                engineBlock(nil, nil);
            }
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getInfoWithNickname:(NSString *)nickname block:(EngineBlock()) engineBlock;
{
    BmobQuery *query = [BmobQuery queryForUser];
    [query includeKey:@"team"];
    [query whereKey:@"nickname" equalTo:nickname];//昵称
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            if (array && [array count] > 0)
            {
                BmobObject *object = [array firstObject];
                UserInfo *dicUser = [[UserInfo alloc] initWithDictionary:object];
                engineBlock(dicUser, nil);
            }else
            {
                //                error = [NSError errorWithDomain:ErrorUnkown code:-1 userInfo:@{NSLocalizedDescriptionKey : @"未知异常"}];
                engineBlock(nil, nil);
            }
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getFriendsWithUser:(BmobUser *)user block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *bquery = [BmobQuery queryForUser];
    [bquery orderByDescending:@"nickname"];
    [bquery whereObjectKey:@"friends" relatedTo:user];
    [bquery includeKey:@"team"];
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


+ (void)updateUserInfoWithUser:(BmobUser *)user avatarImage:(UIImage *)avatar changes:(NSDictionary *)changes block:(void (^)(id, NSError *))engineBlock
{
    
    BDLog(@"*******%@",changes);
    
    for (NSString *key in [changes allKeys])
    {
        [user setObject:[changes objectForKey:key] forKey:key];
    }
    
    
    
    
    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
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
                    [user setObject:avatarFile  forKey:@"avator"];
                    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
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

+ (void)getNearByMatchWithUser:(BmobUser *)user block:(void (^)(id, NSError *))engineBlock
{
    NSString *city = [user objectForKey:@"city"];
    if ([city length] >= 6) {
        city = [NSString stringWithFormat:@"%@00", [city substringToIndex:4]];
    }
    BmobQuery *query = [BmobQuery queryWithClassName:kTableTournament];
    [query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [query orderByAscending:@"start_time"];
    [query whereKey:@"start_time" greaterThanOrEqualTo:[NSDate date]];
    [query whereKey:@"city" equalTo:city];
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

+ (void)getMatchWithTeamId:(NSString *)aTeamId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *query = [BmobQuery queryWithClassName:kTableTournament];
    [query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [query orderByAscending:@"start_time"];
    
//    [query whereKey:@"end_time" greaterThanOrEqualTo:[NSDate date]];
    
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


//获取联赛信息
+ (void)getInfoWithTournament:(NSString *)tournamentId block:(EngineBlock()) engineBlock
{
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"TeamScore"];
    
    [query whereKey:@"league" equalTo:tournamentId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            if (array && [array count] > 0)
            {
//                BmobObject *object = [array firstObject];
                
//                Tournament *dicUser = [[Tournament alloc] initWithDictionary:object];
                
                engineBlock(array, nil);
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

+ (void)getPlayerScoreWithUserId:(NSString *)userId block:(EngineBlock())engineBlock
{
    BmobQuery *query = [BmobQuery queryWithClassName:kTablePlayerScore];
    [query includeKey:@"league,competition,competition.home_court,competition.opponent,competition.home_court.captain,competition.opponent.captain"];
//    [query orderByAscending:@"competition.start_time"];
    query.limit = 1000;
    [query whereKey:@"player" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray array];
            
            for (id obj in array) {
                

                PlayerScore *score = [[PlayerScore alloc] initWithDictionary:obj];
                if ([score.competition.start_time isLaterThanDate:[NSDate dateFromServer]]) {
                    continue ;
                }
                [result addObject:score];
            }
            
            NSComparator cmptr = ^(PlayerScore *obj1, PlayerScore *obj2)
            {
                if ([obj1.competition.start_time isLaterThanDate:obj2.competition.start_time])
                {
                    return (NSComparisonResult)NSOrderedAscending;//升序
                    
                }
                else
                {
                    return (NSComparisonResult)NSOrderedDescending;//降序
                    
                }
                return (NSComparisonResult)NSOrderedSame;
                
            };
            //第一种排序
            NSArray *array = [result sortedArrayUsingComparator:cmptr];
            engineBlock(array, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}


+ (void)addUserId:(NSString *)userId toTeamId:(NSString *)teamId block:(EngineBlock())engineBlock
{
    [self getTeamsWithUserId:userId block:^(id teams, NSError *error)
    {
        if (error) {
            engineBlock(nil, error);
        }else
        {
            NSArray *teamArray = teams;
            if ([teamArray count] <= 1) {
                BmobObject *team = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId];
                BmobObject *user = [BmobUser objectWithoutDatatWithClassName:nil objectId:userId];
                BmobRelation *relationTeam = [BmobRelation relation];
                [relationTeam addObject:user];
                [team addRelation:relationTeam forKey:@"footballer"];
                
                [team updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                 {
                     if (isSuccessful)
                     {
                         engineBlock(nil, nil);
                     }else
                     {
                         engineBlock(nil, error);
                     }
                 }];
            }else
            {
                error = [NSError errorWithDomain:ErrorUnkown code:-1 userInfo:@{NSLocalizedDescriptionKey : @"不能加入超过2支球队"}];
                engineBlock(nil, error);
            }
           
        }
    }];
}




+ (void)getTeamsWithUserId:(NSString *)userId block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
//    [bquery whereObjectKey:@"team" relatedTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    [bquery whereKey:@"footballer" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    [bquery includeKey:@"captain"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
            for (BmobObject *obj in array)
            {
                [result addObject:[[Team alloc] initWithDictionary:obj]];
            }
            engineBlock([NSArray arrayWithArray:result], nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}


+ (void)getScheduleMatchWithUserId:(NSString *)userId block:(EngineBlock())engineBlock
{
    BmobQuery *teamQuery = [BmobQuery queryWithClassName:kTableTeam];
    [teamQuery whereKey:@"footballer" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    
    
    BmobQuery *match1Query = [BmobQuery queryWithClassName:kTableTournament];
    [match1Query whereKey:@"home_court" matchesQuery:teamQuery];
    [match1Query whereKey:@"start_time" greaterThanOrEqualTo:[NSDate dateFromServer]];
    [match1Query orderByAscending:@"start_time"];
    [match1Query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [match1Query findObjectsInBackgroundWithBlock:^(NSArray *array1, NSError *error)
     {
         if (!error)
         {
             BmobQuery *match2Query = [BmobQuery queryWithClassName:kTableTournament];
             [match2Query whereKey:@"opponent" matchesQuery:teamQuery];
             [match2Query whereKey:@"start_time" greaterThanOrEqualTo:[NSDate dateFromServer]];
             [match2Query orderByAscending:@"start_time"];
             [match2Query includeKey:@"home_court,league,opponent"];
             [match2Query findObjectsInBackgroundWithBlock:^(NSArray *array2, NSError *error)
              {
                  NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
                  for (BmobObject *obj1 in array1) {
                      [result addObject:[[Tournament alloc] initWithDictionary:obj1]];
                  }
                  for (int i = 0; i < [array2 count]; i ++)
                  {
                      BOOL isContinue = NO;
                      for (BmobObject *obj1 in array1)
                      {
                          if ([obj1.objectId isEqualToString:[[array2 objectAtIndex:i] objectId]])
                          {
                              isContinue = YES;
                              break ;
                          }
                      }
                      if (isContinue) {
                          continue ;
                      }
                      Tournament *tobj = [[Tournament alloc] initWithDictionary:[array2 objectAtIndex:i]];
                      int j = 0;
                      for (; j < [result count]; j ++)
                      {
                          if ([[[result objectAtIndex:j] start_time] timeIntervalSince1970] > [tobj.start_time timeIntervalSince1970] )
                          {
                              break;
                          }
                      }
                      
                      [result insertObject:tobj atIndex:j];
                      
                  }
                  engineBlock(result, nil);
              }];
         }else
         {
             engineBlock(nil, error);
         }
     }];
    
}

+ (void)searchUserWithKey:(NSString *)key block:(void (^)(id, NSError *))engineBlock
{
    BmobQuery *uQuery = [BmobQuery queryForUser];
    [uQuery whereKey:@"username" matchesWithRegex:key];//用户名
    [uQuery findObjectsInBackgroundWithBlock:^(NSArray *uArray, NSError *error)
    {
        if (!error)
        {
            BmobQuery *nQuery = [BmobQuery queryForUser];
            [nQuery whereKey:@"nickname" matchesWithRegex:key];//昵称
            [nQuery findObjectsInBackgroundWithBlock:^(NSArray *nArray, NSError *error)
            {
                NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
                for (BmobObject *u in uArray)
                {
                    UserInfo *user = [[UserInfo alloc] initWithDictionary:u];
                    if ([user.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
                    {
                        continue;
                    }
                    [result addObject:user];
                }
                for (BmobObject *n in nArray)
                {
                    UserInfo *user = [[UserInfo alloc] initWithDictionary:n];
                    if ([user.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
                    {
                        continue;
                    }
                    BOOL isContinue = NO;
                    for (BmobObject *u in uArray)
                    {
                        if([u.objectId isEqualToString:n.objectId])
                        {
                            isContinue = YES;
                            break;
                        }
                    }
                    
                    if (isContinue) {
                        continue ;
                    }
                    [result addObject:user];
                }
                
                engineBlock([NSArray arrayWithArray:result], nil);
                
            }];
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

@end
