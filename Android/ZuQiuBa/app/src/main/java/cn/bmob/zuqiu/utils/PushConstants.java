package cn.bmob.zuqiu.utils;

/**
 * 消息类型
 * @author venus
 *
 */
public interface PushConstants {
	
	public interface NoticeType{
        /**
         * 个人消息：1、2、10
         */
		int PERSONAL = 1;//个人消息
        /**
         * 球队消息：3、4、5、6、7、8、9、11、13、14、15、16、17、18 、19、22、24、25
         */
		int TEAM = 2;//球队消息
        /**
         * 荣誉：暂无
         */
		int RANKING = 3;//荣誉
        /**
         * 联赛：12, 20，21
         */
        int  LEAGUE = 4;//
	}
	
	public interface NoticeSubType{
        /**
         * 添加好友
         */
		int ADD_FRIEND = 1;//添加好友
        /**
         * 添加好友反馈
         */
		int ADD_FRIEND_FEED = 2;//添加好友反馈
        /**
         * 申请入队
         */
	    int APPLY_TEAM = 3;//申请入队
        /**
         * 申请入队反馈
         */
	    int APPLY_TEAM_FEED = 4;//申请入队反馈
        /**
         * 队长邀请入队
         */
	    int CAPTAIN_INVITATION = 5;//队长邀请入队
        /**
         * 队长邀请入队反馈
         */
	    int CAPTAIN_INVITATION_FEED = 6;//队长邀请入队反馈
        /**
         * 队员邀请入队
         */
	    int MEMBER_INVITATION = 7;//队员邀请入队
        /**
         * 队员邀请入队反馈
         */
        int MEMBER_INVITATION_FEED = 26;//队员邀请入队反馈

        /**
         * 被踢出球队
         */
		int TEAM_KICKOUT = 8;//被踢出球队
        /**
         * 退出球队
         */
		int QUIT_TEAM = 9;//退出球队
        /**
         * 评分
         */
		int MARKING = 10;//评分
        /**
         * 比赛报告
         */
		int MATCH_REPORT = 11;//比赛报告

        /**
         * 阵容发布
         */
		int LINEUP_PUBLISH =13;//阵容发布
        /**
         * 队员创建比赛
         */
		int MENBER_CREATE_COMPE = 14;//队员创建比赛
        /**
         * 队长创建比赛
         */
		int CAPTAIN_CREATE_COMPE = 15;//队长创建比赛
        /**
         * 创建比赛反馈
         */
        int CREATE_COMPE_FEED = 16;
        /**
         * 通知对方队长已变更比分
         */
        int UPDATE_COMPE_SCORE = 17;
        /**
         * 创建比赛
         */
        int CREATE_COMPE = 18;

        /**
         * 联赛邀请
         */
        int LEAGUE_INVITE = 12;
        /**
         * 发布联赛
         */
        int LEAGUE_PUBLISH = 20;
        /**
         * 更新数据
         */
        int LEAGUE_UPDATE = 21;//

        int GAME_AUTH_FAIL = 24;    // 赛事认证失败

        int GAME_AUTH_SUCCESS = 25;     // 赛事认证成功

	}
	
}
