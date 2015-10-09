//
//  MatchEngine.m
//  SportsContact
//
//  Created by bobo on 14-8-4.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "MatchEngine.h"
#import "DateUtil.h"
#include <math.h>

@implementation MatchEngine


+ (void)getMatchWithMatchId:(NSString *)matchId block:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTournament];
    [bquery includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [bquery getObjectInBackgroundWithId:matchId block:^(BmobObject *object, NSError *error) {
         engineBlock([[Tournament alloc] initWithDictionary:object], nil);
        
    }];
}

+ (void)getTeamsWithBlock:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery orderByAscending:@"found_time"];
    bquery.limit = 1000;//上限1000
    [bquery includeKey:@"captain"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
            for (BmobObject *obj in array) {
                [result addObject:[[Team alloc] initWithDictionary:obj] ];
            }
            engineBlock(result, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}


+ (void)searchTeamsWithName:(NSString *)name block:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeam];
    [bquery whereKey:@"name" matchesWithRegex:name];
    [bquery includeKey:@"captain"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
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


+ (void)addMatchWithMatch:(Tournament *)match block:(EngineBlock()) engineBlock
{
    BmobObject *tournament = [[BmobObject alloc] initWithClassName:kTableTournament];
    [tournament setObject:match.name forKey:@"name"];
    [tournament setObject:match.event_date forKey:@"event_date"];
    [tournament setObject:match.start_time forKey:@"start_time"];
    [tournament setObject:match.end_time forKey:@"end_time"];
    [tournament setObject:match.nature forKey:@"nature"];
    [tournament setObject:@(NO) forKey:@"state"];
    [tournament setObject:match.site forKey:@"site"];
    [tournament setObject:match.city forKey:@"city"];
    [tournament setObject:match.nature forKey:@"nature"];
    [tournament setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:match.home_court.objectId] forKey:@"home_court"];
    [tournament setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:match.opponent.objectId]  forKey:@"opponent"];
    
    [tournament saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (!error)
        {
            engineBlock(nil, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getPlayerScoreWithTournament:(NSString *)tournamentId block:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTablePlayerScore];
    [bquery whereKey:@"competition" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:tournamentId]];
    [bquery includeKey:@"competition,league,team,player"];
//    bquery.skip = 0;
    bquery.limit = 100;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
            for (BmobObject *obj1 in array) {
                [result addObject:[[PlayerScore alloc] initWithDictionary:obj1]];
            }
            engineBlock(result, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getPlayerScoreWithTournament:(NSString *)tournamentId teamId:(NSString *)teamId block:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTablePlayerScore];
    [bquery whereKey:@"competition" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:tournamentId]];
    [bquery whereKey:@"team" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId]];
    [bquery includeKey:@"competition,league,team,player"];
    //    bquery.skip = 0;
    bquery.limit = 100;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error)
        {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
            for (BmobObject *obj1 in array) {
                [result addObject:[[PlayerScore alloc] initWithDictionary:obj1]];
            }
            engineBlock(result, nil);
        }else
        {
           
            engineBlock(nil, error);
        }
    }];
}

+ (void)getPlayerScoreWithTournament:(NSString *)tournamentId userId:(NSString *)userId block:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTablePlayerScore];
    [bquery whereKey:@"player" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    [bquery whereKey:@"competition" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:tournamentId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error) {
            if ([array count] > 0)
            {
                engineBlock([[PlayerScore alloc] initWithDictionary:[array firstObject]], nil);
                
            }else
            {
                engineBlock(nil, nil);
            }
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getMatchWithUserId:(NSString *)userId block:(EngineBlock()) engineBlock
{
    BmobQuery *teamQuery = [BmobQuery queryWithClassName:kTableTeam];
    [teamQuery whereKey:@"footballer" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    BmobQuery *match1Query = [BmobQuery queryWithClassName:kTableTournament];
    [match1Query whereKey:@"home_court" matchesQuery:teamQuery];
    [match1Query whereKey:@"start_time" lessThanOrEqualTo:[NSDate date]];
    [match1Query orderByAscending:@"start_time"];
    [match1Query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [match1Query findObjectsInBackgroundWithBlock:^(NSArray *array1, NSError *error)
    {
        if (!error)
        {
            BmobQuery *match2Query = [BmobQuery queryWithClassName:kTableTournament];
            [match2Query whereKey:@"opponent" matchesQuery:teamQuery];
            [match2Query whereKey:@"start_time" lessThanOrEqualTo:[NSDate date]];
            [match2Query orderByAscending:@"start_time"];
            [match2Query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
            [match2Query findObjectsInBackgroundWithBlock:^(NSArray *array2, NSError *error)
             {
                 NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
                 for (BmobObject *obj1 in array1) {
                     [result addObject:[[Tournament alloc] initWithDictionary:obj1]];
                 }
                 for (int i = 0; i < [array2 count]; i ++)
                 {
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

+ (void)getTeamTeamScoreWithTournamentId:(NSString *)tournamentId teamId:(NSString *)teamId block:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableTeamScore];
    [bquery whereKey:@"competition" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:tournamentId]];
    [bquery whereKey:@"team" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
       
        if (!error) {
            if ([array count] > 0)
            {
                engineBlock([[TeamScore alloc] initWithDictionary:[array firstObject]], nil);
                
            }else
            {
                engineBlock(nil, nil);
            }
        }else
        {
            engineBlock(nil, error);
        }
    }];
    
}

+ (void)updatePlayerScoreWithObjectId:(NSString *)objectId changes:(NSDictionary *)changes block:(EngineBlock()) engineBlock
{
    BmobObject *playerScore = [BmobObject objectWithoutDatatWithClassName:kTablePlayerScore objectId:objectId];
    for (id key in changes) {
        [playerScore setObject:[changes objectForKey:key] forKey:key];
    }
    [playerScore updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            engineBlock(nil, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getCommentsWithAcceptUserId:(NSString *)userId tournamentId:(NSString *)tournamentId block:(EngineBlock()) engineBlock;
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableComment];
    [bquery includeKey:@"komm,competition"];
    [bquery whereKey:@"accept_comm" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    [bquery whereKey:@"competition" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:tournamentId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error) {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
            for (BmobObject *obj1 in array) {
                [result addObject:[[Comment alloc] initWithDictionary:obj1]];
            }
            engineBlock(result, nil);
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)getCommentWithAcceptUserId:(NSString *)acceptUserId kommUserId:(NSString *)kommUserId tournamentId:(NSString *)tournamentId block:(EngineBlock()) engineBlock
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:kTableComment];
    [bquery includeKey:@"komm,competition"];
    [bquery whereKey:@"accept_comm" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:acceptUserId]];
     [bquery whereKey:@"komm" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:kommUserId]];
    [bquery whereKey:@"competition" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:tournamentId]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error) {
            if ([array count] > 0)
            {
                engineBlock([[Comment alloc] initWithDictionary:[array firstObject]], nil);
                
            }else
            {
                engineBlock(nil, nil);
            }
        }else
        {
            engineBlock(nil, error);
        }
    }];
}

+ (void)registerTeamToLeagueId:(NSString *)leagueId teamId:(NSString *)teamId block:(EngineBlock()) engineBlock
{
    BmobObject *league = [BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:leagueId];
    BmobObject *team = [BmobUser objectWithoutDatatWithClassName:kTableTeam objectId:teamId];
//    BmobRelation *relationDel = [BmobRelation relation];
//    [relationDel removeObject:team];
//    [league addRelation:relationDel forKey:@"teams"];
    
//    [league updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
//     {
//         if (isSuccessful)
//         {
//             engineBlock(nil, nil);
             BmobRelation *relationAdd = [BmobRelation relation];
             [relationAdd addObject:team];
             [league addRelation:relationAdd forKey:@"regTeams"];
             [league updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                 if (isSuccessful)
                 {
                     engineBlock(nil, nil);
                 }else
                 {
                     engineBlock(nil, error);
                 }
             }];
             
//         }else
//         {
//             engineBlock(nil, error);
//         }
//     }];
}


+ (void)getNextMatchWithUserId:(NSString *)userId block:(EngineBlock()) engineBlock
{
    BmobQuery *teamQuery = [BmobQuery queryWithClassName:kTableTeam];
    [teamQuery whereKey:@"footballer" equalTo:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    BmobQuery *match1Query = [BmobQuery queryWithClassName:kTableTournament];
    [match1Query whereKey:@"home_court" matchesQuery:teamQuery];
    //    [match1Query whereKey:@"start_time" lessThanOrEqualTo:[NSDate date]];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [formatter setDateFormat:@"yyyy-MM-dd 00-00-00"];
    NSString *dateString = [formatter stringFromDate:[NSDate dateFromServer]];
    NSDate *todayDate = [formatter dateFromString:dateString];
    BDLog(@"date %@ dateString %@",todayDate ,dateString);
    
    
    [match1Query whereKey:@"start_time" greaterThanOrEqualTo:todayDate];
    
    [match1Query orderByAscending:@"start_time"];
    [match1Query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
    [match1Query findObjectsInBackgroundWithBlock:^(NSArray *array1, NSError *error)
     {
         if (!error)
         {
             BmobQuery *match2Query = [BmobQuery queryWithClassName:kTableTournament];
             [match2Query whereKey:@"opponent" matchesQuery:teamQuery];
             //             [match2Query whereKey:@"start_time" lessThanOrEqualTo:[NSDate date]];
             
             [match2Query whereKey:@"start_time" greaterThanOrEqualTo:todayDate];
             //             match2Query.limit = 1;
             
             [match2Query orderByAscending:@"start_time"];
             [match2Query includeKey:@"home_court,home_court.captain,league,opponent,opponent.captain"];
             [match2Query findObjectsInBackgroundWithBlock:^(NSArray *array2, NSError *error)
              {
                  Tournament *result = nil;
                  NSDate *nowDate = [NSDate dateFromServer];
                  for (BmobObject *obj1 in array1)
                  {
                      
                      Tournament *tobj = [[Tournament alloc] initWithDictionary:obj1];
                      if (result)
                      {
                          NSTimeInterval time1 = fabs([[result start_time] timeIntervalSince1970] - [nowDate timeIntervalSince1970]);
                          NSTimeInterval time2 = fabs([[tobj start_time] timeIntervalSince1970] - [nowDate timeIntervalSince1970]);
                          if (time2 < time1) {
                              result = tobj;
                          }
                          
                      }else
                      {
                          result = tobj;
                      }
                      
                  }
                  for (BmobObject *obj2 in array2) {
                      Tournament *tobj = [[Tournament alloc] initWithDictionary:obj2];
                      if (result)
                      {
                          NSTimeInterval time1 = fabs([[result start_time] timeIntervalSince1970] - [nowDate timeIntervalSince1970]);
                          NSTimeInterval time2 = fabs([[tobj start_time] timeIntervalSince1970] - [nowDate timeIntervalSince1970]);
                          if (time2 < time1) {
                              result = tobj;
                          }
                          
                      }else
                      {
                          result = tobj;
                      }
                  }
                  engineBlock(result, nil);
              }];
         }else
         {
             engineBlock(nil, error);
         }
     }];
}

@end
