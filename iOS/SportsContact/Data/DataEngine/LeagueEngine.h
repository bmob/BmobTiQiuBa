//
//  LeagueEngine.h
//  SportsContact
//
//  Created by Nero on 8/14/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDef.h"


@interface LeagueEngine : NSObject



/**
 *  获取用户所在球队
 *
 *  @param user 当前用户
 */
+ (void)getTeamsWithUser:(BmobUser *)user block:(EngineBlock())engineBlock;



/**
 *  获取球队所参加的赛事
 *
 *  @param aTeamId 球队id
 */
//+ (void)getLastMatchWithTeamId:(NSString *)aTeamId block:(EngineBlock())engineBlock;

+ (void)getHomeMatchWithTeamId:(NSString *)aTeamId block:(EngineBlock())engineBlock;

+ (void)getGuestMatchWithTeamId:(NSString *)aTeamId block:(EngineBlock())engineBlock;

//获取最近参加的联赛的信息
+(void)getLastLeagueMatchWithTeamId:(NSString *)aTeamId block:(void (^)(id, NSError *))engineBlock;

/**
 *  获取赛事属于的联赛
 *
 *  @param tournamentId 赛事id
 */
+ (void)getLeagueWithTournamentId:(NSString *)tournamentId block:(EngineBlock())engineBlock;





/**
 *  获取附近联赛
 *
 *  @param cityCode 用户城市
 */
+ (void)getNearbyLeagueWithCitycode:(NSString *)cityCode block:(EngineBlock())engineBlock;




/**
 *  获取搜索的联赛
 *
 *  @param touramentName 联赛名字
 */
+ (void)getSearchWithTouramentName:(NSString *)touramentName block:(EngineBlock())engineBlock;





/**
 *  获取联赛球队积分表
 *
 *  @param leagueId 联赛id
 */
+ (void)getTeamscoreWithLeagueId:(NSString *)leagueId block:(EngineBlock())engineBlock;




/**
 *  获取联赛射手榜
 *
 *  @param leagueId 联赛id
 */
+ (void)getPlayerscoreWithLeagueId:(NSString *)leagueId block:(EngineBlock())engineBlock;



/**
 *  获取联赛各比赛结果
 *
 *  @param leagueId 联赛id
 */
+ (void)getLeagueResultWithLeagueId:(NSString *)leagueId block:(EngineBlock())engineBlock;




/**
 *  获取联赛各比赛赛程
 *
 *  @param leagueId 联赛id
 */
+ (void)getLeagueScheduleWithLeagueId:(NSString *)leagueId block:(EngineBlock())engineBlock;



/**
 *  获取联赛各比赛进球人员
 *
 *  @param leagueId 比赛id
 */
+ (void)getFootballerGoalWithLeagueId:(NSString *)leagueId block:(EngineBlock())engineBlock;





/**
 *  获取某球队的参加的全部联赛
 *
 *  @param leagueId 比赛id
 */
+ (void)getAllLeagueWithTeamId:(NSString *)teamId block:(EngineBlock())engineBlock;


//加入联赛
+(void)joinLeagueWithTeamId:(NSString *)teamId leagueId:(NSString *)leagueId block:(void(^)(BOOL isSuccessful,NSError *error))block;



@end
