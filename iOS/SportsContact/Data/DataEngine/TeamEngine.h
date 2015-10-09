//
//  TeamEngine.h
//  SportsContact
//
//  Created by Nero on 8/7/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDef.h"


@interface TeamEngine : NSObject


/**
 *  获取用户所在球队
 *
 *  @param user 当前用户
 */
+ (void)getTeamsWithUser:(BmobUser *)user block:(EngineBlock())engineBlock;


/**
 *  获取用户所在球队的id数组
 *
 *  @param user        当前用户
 *  @param engineBlock 回调函数
 */
+(void)getTeamsObjectIdWith:(BmobUser *)user block:(EngineBlock())engineBlock;


/**
 *  获取用户加入的全部球队
 *
 *  @param user 当前用户
 */
+ (void)getJoinedTeamsWithUserId:(NSString *)userId block:(EngineBlock())engineBlock;

/**
 *  获取球队的所有队员,排除队长
 *
 *  @param teamId      球队ID
 *  @param engineBlock
 */
+ (void)getTeamMembersWithTeamId:(NSString *)teamId block:(EngineBlock())engineBlock;

/**
 *  切换球队
 *
 *  @param team 当前球队
 *  @param user 当前用户
 */
+ (void)getSwitchTeamsWithTeamId:(NSString *)teamId  UserId:(NSString *)userId block:(EngineBlock())engineBlock;


/**
 *  退出球队
 *
 *  @param user 当前用户
 */
+ (void)getQuitTeamsWithTeamId:(NSString *)teamId  UserId:(NSString *)userId block:(EngineBlock())engineBlock;



/**
 *  删除球队
 *
 */
+ (void)getDeleteTeamsWithTeamId:(NSString *)teamId block:(EngineBlock())engineBlock;







/**
 *  获取球队
 *
 *  @param teamId 球队id
 */
+ (void)getInfoWithTeamId:(NSString *)teamId block:(EngineBlock()) engineBlock;
+ (void)getInfoWithTeamname:(NSString *)teamname block:(EngineBlock()) engineBlock;



/**
 *  获取附近比赛
 *
 *  @param cityCode 用户地址
 */
+ (void)getNearbyTeamWithUserCity:(NSString *)cityCode block:(EngineBlock()) engineBlock;




/**
 *  搜索球队
 *
 *  @param teamname 球队名
 */
+ (void)getSearchTeamWithTeamname:(NSString *)teamname block:(EngineBlock()) engineBlock;




/**
 *  模糊搜索球队
 *
 *  @param teamname 球队key
 */
+ (void)getFuzzySearchTeamWithTeamname:(NSString *)teamname block:(EngineBlock()) engineBlock;









/**
 *  获取球队的全部人数
 *
 *  @param teamId 球队id
 */
+ (void)getTeamMenberCountWithTeamId:(NSString *)teamId block:(EngineBlock()) engineBlock;



/**
 *  获取赛程
 *
 *  @param aTeamId     球队ID
 */
+ (void)getMatchWithTeamId:(NSString *)aTeamId block:(EngineBlock())engineBlock;

+ (void)getAllHomeTouramentWithTeamId:(NSString *)aTeamId limit:(int)limit block:(EngineBlock())engineBlock;
+ (void)getAllGusstTouramentWithTeamId:(NSString *)aTeamId limit:(int)limit block:(EngineBlock())engineBlock;


/**
 *  获取最近的比赛
 *
 *  @param aTeamId     球队ID
 *  @param engineBlock 回调结果
 */
+(void)getLastestTouramentWithTeamId:(NSString *)aTeamId  block:(void (^)(id, NSError *))engineBlock;

/**
 *  获取最新的即将开始的比赛
 *
 *  @param aTeamId     球队ID
 *  @param engineBlock 回调结果
 */
+(void)getNearestTouramentWithTeamId:(NSString *)aTeamId  block:(void (^)(id, NSError *))engineBlock;


+(void)getAllTouramentWithTeamId:(NSString *)aTeamId limit:(int)limit block:(void (^)(id, NSError *))engineBlock;



/**
 *  更新球队信息
 *
 *  @param teamId    球队对象
 *  @param avatar  头像图片
 *  @param changes 更改的键值对
 */
+ (void)updateTeamInfoWithteamId:(NSString *)user avatarImage:(UIImage *)avatar changes:(NSDictionary *)changes  block:(EngineBlock()) engineBlock;



/**
 *  更换队长
 *
 *  @param userId    队长id
 */
+ (void)changeCaptainWithteamId:(NSString *)teamId captainUserid:(NSString *)userId block:(EngineBlock()) engineBlock;

/**
 *  获取球队阵容信息
 *
 *  @param teamId    球队id
 */
+ (void)getLineupWithTeamId:(NSString *)teamId block:(EngineBlock())engineBlock;


/**
 *  创建球队阵容
 *
 *  @param teamId    球队id
 */
+ (void)createLineupWithTeamId:(NSString *)teamId block:(EngineBlock())engineBlock;


/**
 *  更新球队阵容
 *
 *  @param teamId    球队id
 */
+ (void)upDateLineupWithTeamId:(NSString *)teamId block:(EngineBlock())engineBlock;



/**
 *  获得个人比赛信息
 *
 *  @param userd    用户id
 */
+ (void)getPlayerScoreWithUserID:(NSString *)userId block:(EngineBlock())engineBlock;


/**
 *  获取用户创建的联赛数目
 *
 *  @param userId 用户id
 *  @param block  回调
 */
+(void)getLeagueGamesNumberWithUserID:(NSString *)userId block:(void(^)(NSInteger count,NSError *error))block;



@end
