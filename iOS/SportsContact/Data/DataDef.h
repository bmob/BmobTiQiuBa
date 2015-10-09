//
//  DataDef.h
//  SportsContact
//
//  Created by bobo on 14-7-11.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "Jastor.h"
#import <BmobSDK/Bmob.h>


#define kObserverUserInfoChanged @"kObserverUserInfoChanged"
#define kObserverTeamInfoChanged @"kObserverTeamInfoChanged"
#define kObserverMatchAdded @"kObserverMatchAdded"
#define kObserverMatchInfoChanged @"kObserverMatchInfoChanged"
#define kObserverNoticeRecieve @"kObserverNoticeRecieve"
#define kObserverCommentScoreChanged @"kObserverCommentScoreChanged"
#define kObserverUnreadNoticeChanged @"kObserverUnreadNoticeChanged"

#define ErrorUnkown @"ErrorUnkown"
#define EngineBlock(blockName) void(^blockName)(id result, NSError *error)

#define UrlLeageManage @"http://tq.codenow.cn"

/**
 *  球队表
 */
#define kTableTeam @"Team"

/**
 *  阵容表
 */
#define kTableLineup @"Lineup"
/**
 *  赛事表
 */
#define kTableTournament @"Tournament"

/**
 *  联赛表
 */
#define kTableLeague @"League"

/**
 *  球队赛事积分表
 */
#define kTableTeamScore @"TeamScore"

/**
 *  球员赛事积分表
 */
#define kTablePlayerScore @"PlayerScore"

/**
 *  球员评分表
 */
#define kTableComment @"Comment"

/**
 *  消息表（本地）
 */
#define kTableNotice @"Notice"

/**
 *  联赛积分统计表
 */
#define kTableLeagueScoreStat @"LeagueScoreStat"

/**
 *  推送消息表
 *
 */
#define kTablePushMsg @"PushMsg"

/**
 *  联赛分组表
 *
 */
#define kTableGroup  @"Group"

/**
 *  场上位置类型
 */
typedef NS_OPTIONS(NSInteger, PositioningType) {
    PositioningTypeGoalkeeper = 1,
    PositioningTypeBack,
    PositioningTypeMidfielder,
    PositioningTypeForward,
    
};

NSString *positioningTypeStringFromEnum(PositioningType enumValue);

/**
 *  擅长脚类型
 */
typedef NS_OPTIONS(NSInteger, BegoodType) {
    BegoodTypeLeft = 1,
    BegoodTypeRight,
    BegoodTypeAll
    
};

NSString *begoodTypeStringFromEnum(BegoodType enumValue);

/**
 *  比赛类型
 */
typedef NS_OPTIONS(NSInteger, TournamentType) {
    TournamentTypeGroup = 1,
    TournamentTypeKnockout,
    TournamentTypeFriendly

};

NSString *tournamentTypeStringFromEnum(TournamentType enumValue);

/**
 *  消息类型
 */
typedef NS_OPTIONS(NSInteger, NoticeType) {
    NoticeTypePersonal = 1, //个人
    NoticeTypeTeam,     //球队
    NoticeTypeRanking,    //荣誉
    NoticeTypeLeague,     //联赛
};

/**
 *  消息操作类型
 */
typedef NS_OPTIONS(NSInteger, NoticeSubtype) {
    NoticeSubtypeAddFriend = 1,              //添加好友
    NoticeSubtypeAddFriendFeed = 2,          //添加好友反馈
    NoticeSubtypeApplyTeam = 3,              //申请入队
    NoticeSubtypeApplyTeamFeed = 4,          //申请入队反馈
    NoticeSubtypeCaptainInvitation = 5,      //队长邀请入队
    NoticeSubtypeCaptainInvitationFeed = 6,  //队长邀请入队反馈
    NoticeSubtypeMemberInvitation = 7,       //队员邀请入队
    NoticeSubtypeTeamKickout = 8,            //被踢出球队
    NoticeSubtypeQuitTeam = 9,               //退出球队
    NoticeSubtypeMarking = 10,               //评分
    NoticeSubtypeMatchReport = 11,           //比赛报告
    NoticeSubtypeLeagueInvite = 12,          //联赛邀请
    NoticeSubtypeTeamLineupPub = 13,         //发布阵容
    NoticeSubtypeMatchMemberInvitation = 14, //队员创建比赛
    NoticeSubtypeMatchCaptainInvitation = 15,//队长创建比赛
    NoticeSubtypeMatchInvitationFeed = 16,   //创建比赛反馈
    NoticeSubtypeMatchReportOtherFeed = 17,  //通知对方一已变更比分
    NoticeSubtypeMatchCreated = 18,          //创建比赛
    NoticeSubtypeMatchNotices = 19,          //赛事提醒
    NoticeSubtypeScheduleCreated = 20,       //发布赛程
    NoticeSubtypeScheduleDataUpdated = 21,      //更新数据,联赛A更新积分榜、射手榜
    NoticeSubtypeMatchResultCreated = 22,       //输入比赛结果
    NoticeSubtypeLeagueInvation  = 23,           //邀请参加联赛
    NoticeSubtypeMatchReportFail = 24,           //比赛报告认证失败
    NoticeSubtypeMatchReportSuccess = 25         //比赛报告认证成功
};

/**
 *  消息状态
 */
typedef NS_OPTIONS(NSInteger, NoticeStatus) {
    NoticeStatusReceived = 1,  //收到
    NoticeStatusUnread,        //未读
    NoticeStatusRead,          //已读
    NoticeStatusUndisposed,    //未处理
    NoticeStatusDisposed       //已处理
};


@class UserInfo;
@class Team;
@class Lineup;
@class Tournament;
@class League;
@class TeamScore;
@class PlayerScore;

/**
 *  用户信息
 */
@interface UserInfo : Jastor

/**
 *  用户名
 */
@property (nonatomic, strong) NSString *username;

/**
 *  昵称
 */
@property (nonatomic, strong) NSString *nickname;

/**
 *  头像
 */
@property (nonatomic, strong) BmobFile *avator;

/**
 *  邀请码
 */
@property (nonatomic, strong) NSNumber *invitation;

/**
 *  出生年月
 */
@property (nonatomic, strong) NSDate *birthday;

/**
 *  场中位置
 */
@property (nonatomic, strong) NSNumber *midfielder;

/**
 *  擅长脚
 */
@property (nonatomic, strong) NSNumber *be_good;
@property (nonatomic, strong) NSNumber *stature;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSString *city;
//@property (nonatomic, strong) BmobRelation *team;
//@property (nonatomic, strong) NSNumber *games;
//@property (nonatomic, strong) NSNumber *goals;
//@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) NSNumber *games;
@property (nonatomic, strong) NSNumber *gamesTotal;
@property (nonatomic, strong) NSNumber *goals;
@property (nonatomic, strong) NSNumber *goalsTotal;
@property (nonatomic, strong) NSNumber *assists;
@property (nonatomic, strong) NSNumber *assistsTotal;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) BmobRelation *friends;

@end








/**
 *  球队信息
 */
@interface Team : Jastor

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) BmobFile *avator;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSDate *found_time;
@property (nonatomic, strong) NSString *gsl_code;
@property (nonatomic, strong) UserInfo *captain;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) BmobRelation *footballer;
@property (nonatomic, strong) Lineup *lineup;
@property (nonatomic, strong) NSNumber *appearances;
@property (nonatomic, strong) NSNumber *appearancesTotal;
@property (nonatomic, strong) NSNumber *win;
@property (nonatomic, strong) NSNumber *winTotal;
@property (nonatomic, strong) NSNumber *draw;
@property (nonatomic, strong) NSNumber *drawTotal;
@property (nonatomic, strong) NSNumber *loss;
@property (nonatomic, strong) NSNumber *lossTotal;
@property (nonatomic, strong) NSNumber *goals;
@property (nonatomic, strong) NSNumber *goalsTotal;
@property (nonatomic, strong) NSNumber *goals_against;
@property (nonatomic, strong) NSNumber *goalsAgainstTotal;
@property (nonatomic, strong) NSNumber *goal_difference;
@property (nonatomic, strong) NSNumber *goalDifferenceTotal;
@property (copy, nonatomic) NSString *reg_code;
@end



/**
 *  球队阵容信息
 */
@interface Lineup : Jastor

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) BmobRelation *back;
@property (nonatomic, strong) BmobRelation *striker;
@property (nonatomic, strong) BmobRelation *forward;
@property (nonatomic, strong) UserInfo *goalkeeper;



@end






/**
 *  赛事
 */
@interface Tournament : Jastor

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *event_date;
@property (nonatomic, strong) NSDate *start_time;
@property (nonatomic, strong) NSDate *end_time;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSNumber *nature;
@property (nonatomic) BOOL state;
@property (nonatomic, strong) League *league;
@property (nonatomic, strong) Team *home_court;
@property (nonatomic, strong) Team *opponent;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *score_h;
@property (nonatomic, strong) NSString *score_o;
@property (nonatomic, strong) NSString *score_h2;
@property (nonatomic, strong) NSString *score_o2;
@property (nonatomic) BOOL isVerify;

@end

/**
 *  联赛
 */
@interface League : Jastor

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSArray *playground;
@property (nonatomic, strong) NSNumber *people;
@property (nonatomic, strong) NSNumber *group_count;
@property (nonatomic) BOOL knockout;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) UserInfo *master;
@end

/**
 *  球队赛事积分
 */
@interface TeamScore : Jastor

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) League *league;
@property (nonatomic, strong) Tournament *competition;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSNumber *win;
@property (nonatomic, strong) NSNumber *draw;
@property (nonatomic, strong) NSNumber *loss;
@property (nonatomic, strong) NSNumber *goals;
@property (nonatomic, strong) NSNumber *goals_against;
@property (nonatomic, strong) NSNumber *goal_difference;
@property (nonatomic, strong) NSNumber *score;



@end


/**
 *  球员赛事积分
 */
@interface PlayerScore : Jastor

@property (nonatomic, strong) UserInfo *player;
@property (nonatomic, strong) League *league;
@property (nonatomic, strong) Tournament *competition;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSNumber *avg;
@property (nonatomic, strong) NSNumber *goals;
@property (nonatomic, strong) NSNumber *assists;

@end

@interface Comment : Jastor

@property (nonatomic, strong) UserInfo *accept_comm;
@property (nonatomic, strong) UserInfo *komm;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) Tournament *competition;

@end

/**
 *  联赛积分统计表
 */
@interface LeagueScoreStat : Jastor

@property (nonatomic, strong) League *league;
@property (nonatomic, strong) Team *team;

//@property (nonatomic, strong) NSString *groupName;
//@property (nonatomic, strong) NSString *teamName;
@property (nonatomic, strong) NSNumber *win;
@property (nonatomic, strong) NSNumber *draw;
@property (nonatomic, strong) NSNumber *loss;
@property (nonatomic, strong) NSNumber *goals;
@property (nonatomic, strong) NSNumber *goalsAgainst;
@property (nonatomic, strong) NSNumber *goalDifference;
@property (nonatomic, strong) NSNumber *points;
@property (nonatomic, copy  ) NSString *name;



@end



//@interface PushMsg : Jastor
//
//@property (nonatomic, strong) NSString *belongId;
//@property (nonatomic, strong) NSString *belongNick;
//@property (nonatomic, strong) NSString *belongUsername;
//@property (nonatomic, strong) NSString *content;
//@property (nonatomic) BOOL isRead;
//@property (nonatomic) NSInteger status;
//@property (nonatomic) NSInteger msgType;
//@property (nonatomic) NSString *extra;
//
//@end












@interface ApsInfo : Jastor
/**
 *  内容
 */
@property (nonatomic, strong) NSString *alert;

/**
 *
 */
@property (nonatomic, assign) NSInteger badge;

/**
 *
 */
@property (nonatomic, strong) NSString *sound;

+ (ApsInfo *)apsInfoWithAlert:(NSString *)aAlert badge:(NSInteger)aBadge sound:(NSString *)aSound;

- (NSDictionary *)getDictionary;
- (NSString *)getString;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithString:(NSString *)string;

@end


@interface Notice : Jastor<NSCopying>

/**
 *  本地保存唯一ID，不包含进推送数据
 */
//@property (nonatomic, assign) NSString *objectId;

/**
 *  推送数据
 */
@property (nonatomic, strong) ApsInfo *aps;

/**
 *  发送者username (一般用于反馈)
 */
@property (nonatomic, strong) NSString *belongId;

/**
 *  目标ID (一般是该消息需要操作对应对象的ID)
 */
@property (nonatomic, strong) NSString *targetId;

/**
 *  标题
 */
@property (nonatomic, strong) NSString *title;

/**
 *  推送时间
 */
@property (nonatomic, assign) NSInteger time;

/**
 *  类型  NoticeType
 */
@property (nonatomic, assign) NSInteger type;

/**
 *  操作类型 NoticeSubtype
 */
@property (nonatomic, assign) NSInteger subtype;

/**
 *  状态，本地状态 NoticeStatus
 */
@property (nonatomic, assign) NSInteger status;

/**
 *  扩展数据
 */
@property (nonatomic, strong) NSDictionary *extra;

- (NSDictionary *)getDictionary;
- (NSString *)getString;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithString:(NSString *)string;

@end

/**
 *  地区的信息
 */
@interface LocationInfo : NSObject <NSCopying>

@property (nonatomic, strong) NSNumber *provinceCode;
@property (nonatomic, strong) NSString *provinceName;
@property (nonatomic, strong) NSNumber *cityCode;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSNumber *districtCode;
@property (nonatomic, strong) NSString *districtName;

@end


/**
 *  备选项信息
 */
@interface OptionInfo : Jastor
@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, strong) NSString *value;

+ (OptionInfo *)optionWithKey:(NSNumber *)aKey value:(NSString *)aValue;
@end

/**
 *  省市区的备选项
 */
@interface PCDOptionInfo : NSObject

// key : 区域代码 ; value: 区域名称
@property (nonatomic, strong) OptionInfo *regionInfo;
@property (nonatomic, strong) NSArray *subArray;

+ (PCDOptionInfo *)infoWithDic:(NSDictionary *)aDic;
- (NSArray *)optionsArray;
- (NSArray *)namesArray;
- (PCDOptionInfo *)subInfoOfName:(NSString *)aName;
- (PCDOptionInfo *)subInfoOfCode:(NSNumber *)aCode;

@end