//
//  InfoEngine.h
//  SportsContact
//
//  Created by bobo on 14-7-17.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataDef.h"

@interface InfoEngine : NSObject

/**
 *  获取用户信息
 *
 *  @param userId 用户ID
 */
+ (void)getInfoWithUserId:(NSString *)userId block:(EngineBlock()) engineBlock;

/**
 *  获取用户信息
 *
 *  @param username username 用户名
 */
+ (void)getInfoWithUsername:(NSString *)username block:(EngineBlock()) engineBlock;

/**
 *  获取用户信息
 *
 *  @param nickname nickname 昵称
 */
+ (void)getInfoWithNickname:(NSString *)nickname block:(EngineBlock()) engineBlock;

/**
 *  获取用户的朋友列表
 *
 *  @param user 用户对象
 */
+ (void)getFriendsWithUser:(BmobUser *)user block:(EngineBlock()) engineBlock;

/**
 *  添加好友
 *
 *  @param user 用户
 */
//+ (void)addFriendsWithUser:(BmobUser *)user block:(EngineBlock()) engineBlock;

/**
 *  更新用户信息
 *
 *  @param user    用户对象
 *  @param avatar  头像图片
 *  @param changes 更改的键值对
 */
+ (void)updateUserInfoWithUser:(BmobUser *)user avatarImage:(UIImage *)avatar changes:(NSDictionary *)changes  block:(EngineBlock()) engineBlock;

/**
 *  获取附近比赛
 *
 *  @param user 用户
 */
+ (void)getNearByMatchWithUser:(BmobUser *)user block:(EngineBlock()) engineBlock;

/**
 *  获取赛程
 *
 *  @param aTeamId     球队ID
 */
+ (void)getMatchWithTeamId:(NSString *)aTeamId block:(EngineBlock())engineBlock;

/**
 *  获取用户战绩
 *
 *  @param userId      用户ID
 */
+ (void)getPlayerScoreWithUserId:(NSString *)userId block:(EngineBlock())engineBlock;

/**
 *  获取联赛信息
 *
 *  @param tournamentId tournamentId 联赛id
 */
+ (void)getInfoWithTournament:(NSString *)tournamentId block:(EngineBlock()) engineBlock;

/**
 *  添加球员到球队
 *
 *  @param userId      用户ID
 *  @param teamId      球队ID
 *  @param engineBlock
 */
+ (void)addUserId:(NSString *)userId toTeamId:(NSString *)teamId block:(EngineBlock())engineBlock;

/**
 *  获取用户所属的球队数组
 *
 *  @param userId      用户ID
 *  @param engineBlock 
 */
+ (void)getTeamsWithUserId:(NSString *)userId block:(EngineBlock())engineBlock;

/**
 *  获取赛程
 *
 *  @param userId      用户ID
 *  @param engineBlock
 */
+ (void)getScheduleMatchWithUserId:(NSString *)userId block:(EngineBlock())engineBlock;

/**
 *  搜索用户
 *
 *  @param key         搜索关键字
 *  @param engineBlock engineBlock
 */
+ (void)searchUserWithKey:(NSString *)key block:(EngineBlock())engineBlock;

@end
