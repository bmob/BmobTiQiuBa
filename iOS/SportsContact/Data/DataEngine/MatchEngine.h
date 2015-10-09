//
//  MatchEngine.h
//  SportsContact
//
//  Created by bobo on 14-8-4.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDef.h"

@interface MatchEngine : NSObject

/**
 *  获取比赛
 *
 *  @param matchId 比赛ID
 */
+ (void)getMatchWithMatchId:(NSString *)matchId block:(EngineBlock()) engineBlock;

/**
 *  获取的球队
 *
 */
+ (void)getTeamsWithBlock:(EngineBlock()) engineBlock;

/**
 *  查找球队，like查找
 *
 *  @param name 球队名字
 */
+ (void)searchTeamsWithName:(NSString *)name block:(EngineBlock()) engineBlock;

/**
 *  添加比赛
 *
 *  @param match 比赛对象
 */
+ (void)addMatchWithMatch:(Tournament *)match block:(EngineBlock()) engineBlock;

/**
 *  获取用户已结束的比赛.
 *
 *  @param userId 用户ID
 */
+ (void)getMatchWithUserId:(NSString *)userId block:(EngineBlock()) engineBlock;

/**
 *  获取用户下一场比赛
 *
 *  @param userId userId
 */
+ (void)getNextMatchWithUserId:(NSString *)userId block:(EngineBlock()) engineBlock;

/**
 *  获取球队的赛事积分数据
 *
 *  @param tournamentId 赛事ID
 *  @param teamId       球队ID
 */
+ (void)getTeamTeamScoreWithTournamentId:(NSString *)tournamentId teamId:(NSString *)teamId block:(EngineBlock()) engineBlock;

/**
 *  获取一场比赛的一位球员积分
 *
 *  @param tournamentId 比赛ID
 *  @param userId       用户ID
 */
+ (void)getPlayerScoreWithTournament:(NSString *)tournamentId userId:(NSString *)userId block:(EngineBlock()) engineBlock;

/**
 *  获取一场比赛的球员积分列表
 *
 *  @param tournamentId 比赛ID
 */
+ (void)getPlayerScoreWithTournament:(NSString *)tournamentId block:(EngineBlock()) engineBlock;

/**
 *  获取一场比赛的球员积分列表
 *
 *  @param tournamentId 比赛ID
 *  @param teamId       球队ID
 *  @param engineBlock  结果信息
 */
+ (void)getPlayerScoreWithTournament:(NSString *)tournamentId teamId:(NSString *)teamId block:(EngineBlock()) engineBlock;

/**
 *  更新一场比赛的一位球员积分
 *
 *  @param objectId 球员积分ID
 */
+ (void)updatePlayerScoreWithObjectId:(NSString *)objectId changes:(NSDictionary *)changes block:(EngineBlock()) engineBlock;

/**
 *  获取用户的评分列表
 *
 *  @param userId       用户ID
 *  @param tournamentId 比赛ID
 */
+ (void)getCommentsWithAcceptUserId:(NSString *)userId tournamentId:(NSString *)tournamentId block:(EngineBlock()) engineBlock;


/**
 *  获取用户的评分
 *
 *  @param acceptUserId 被评人ID
 *  @param kommUserId   评人ID
 *  @param tournamentId 比赛ID
 */
+ (void)getCommentWithAcceptUserId:(NSString *)acceptUserId kommUserId:(NSString *)kommUserId tournamentId:(NSString *)tournamentId block:(EngineBlock()) engineBlock;


+ (void)registerTeamToLeagueId:(NSString *)leagueId teamId:(NSString *)teamId block:(EngineBlock()) engineBlock;

@end
