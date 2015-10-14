package cn.bmob.zuqiu.utils;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONObject;

import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.PushMsg;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class PushMessageHelper {

    /**
     * 队长邀请入队的消息
     * @param team
     * @return
     */
    public static PushMessage inviteByCaptainMessage(Context context,Team team){
        //组装PushMessage对象
        User user = BmobUser.getCurrentUser(context, User.class);
        String username = TextUtils.isEmpty(user.getNickname()) ? user.getUsername() : user.getNickname();
        String belongId = user.getUsername();//谁发送这条消息就填谁的手机号
        String title = team.getName();//球队名
        String alert= username + "邀请您加入球队"+team.getName();
        String targetId = team.getObjectId();//球队ID
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.CAPTAIN_INVITATION);
        return msg;
    }

    /**
     * 创建队长邀请入队的反馈消息（由被邀请方发送给队长的同意加入战队的反馈消息）
     * @param context
     * @param msg
     * @return
     */
    public static PushMessage getInviteFeedMessage(Context context,PushMessage msg){
        User user = BmobUser.getCurrentUser(context, User.class);
        String username = TextUtils.isEmpty(user.getNickname()) ? user.getUsername() : user.getNickname();
        String title = username;//
        String teamName = msg.getTitle();
        String belongId = user.getUsername();//发送者的用户名
        String targetId = msg.getTargetId();
        String alert = username+"加入您的"+teamName+"球队";
        PushMessage feed = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,PushConstants.NoticeSubType.CAPTAIN_INVITATION_FEED);
        return feed;
    }

    /**
     * 创建新成员加入球队的消息（以队长邀请的方式加入的球队）,被邀请方给球队的所有成员发送一条
     * @param context
     * @param msg
     * @return
     */
    public static PushMessage getNewMemberMsgByInvite(Context context,PushMessage msg){
        User user = BmobUser.getCurrentUser(context, User.class);
        String username = TextUtils.isEmpty(user.getNickname()) ? user.getUsername() : user.getNickname();
        String teamName = msg.getTitle();
        String title = teamName;
        String alert = "新成员"+username + "加入了"+teamName+"球队";
        String belongId = user.getUsername();//发送者的userName
        String targetId = msg.getTargetId();//可为空
        PushMessage feed = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,PushConstants.NoticeSubType.CAPTAIN_INVITATION_FEED);
        return feed;
    }

    /**
     * 队员邀请入队:这条消息是先发送给队长，由队长同意后再发送给被邀请人
     * @param team
     * @param inviteUser
     * @param targetUser
     * @return
     */
    public static PushMessage inviteByMemberMessage(Team team,User inviteUser,User targetUser){
        String belongId = inviteUser.getUsername();//谁发送这条消息就填谁的手机号
        String inviteName = TextUtils.isEmpty(inviteUser.getNickname()) ? inviteUser.getUsername() : inviteUser.getNickname();//取昵称，没有再用手机号代表
        String title = inviteName+"&"+team.getName();//邀请方的用户名&球队名
        String targetName = TextUtils.isEmpty(targetUser.getNickname()) ? targetUser.getUsername() : targetUser.getNickname();//取昵称，没有再用手机号代表
//        String title = inviteName;//邀请方的用户名
        String alert = inviteName+"认为您应该邀请"+targetName+"加入球队，提升球队实力";
        String targetId = team.getObjectId()+"&"+targetUser.getUsername(); // 发送者所在的球队ID&被邀请者的用户名
        PushMessage  msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.MEMBER_INVITATION);
        return msg;
    }

    /**
     * 队长处理队员的邀请他人加入球队的信息
     */
    public static PushMessage dealMemberInvite(Context context,PushMessage msg){
        //组装PushMessage对象
        User currentUser = BmobUser.getCurrentUser(context, User.class);
        String belongId = currentUser.getUsername();//谁发送这条消息就填谁的手机号
        String teamName="";
        String msgTagId = "";
        try{
            teamName = msg.getTitle().split("&")[1];
            msgTagId = msg.getTargetId().split("&")[0];//取前面一个值
        }catch(Exception exc){
            teamName = msg.getTitle();
            msgTagId = msg.getTargetId();
        }
        final String alert = "邀请您加入球队"+teamName;
        String title = teamName;//球队名
        final String targetId =msgTagId;
        PushMessage push = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.CAPTAIN_INVITATION);
        return push;
    }

    /**
     * 构造申请入队的消息
     * @param context
     * @param targetTeam
     * @return
     */
    public static PushMessage getApplyTeamMessage(Context context,Team targetTeam){
        User user = BmobUser.getCurrentUser(context, User.class);
        String name = TextUtils.isEmpty(user.getNickname())?user.getUsername():user.getNickname();
        String alert = name + "申请加入"+targetTeam.getName();
        String belongId = user.getUsername();//发送者的userName
        String targetId = targetTeam.getObjectId()+"&"+user.getObjectId();//球队ID&发送者的id
        String title = name+"&"+targetTeam.getName();//申请方的用户名&球队名
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,PushConstants.NoticeSubType.APPLY_TEAM);
        return msg;
    }

    /**
     * 创建新成员加入球队的消息（申请入队方式加入的球队）
     * @param context
     * @param msg
     * @return
     */
    public static PushMessage getNewMemberMsgByApply(Context context,PushMessage msg){
        User user = BmobUser.getCurrentUser(context, User.class);
        String name = "";
        String teamName = "";
        try{
            name = msg.getTitle().split("&")[0];
            teamName = msg.getTitle().split("&")[1];
        }catch(Exception exc){
            name = teamName = msg.getTitle();
        }
        String alert = name + "成功的加入了您所属的"+teamName+"球队";
        String belongId = user.getUsername();//发送者的userName
        String targetId = msg.getBelongId();
        String title = teamName;//球队名
        PushMessage feed = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,PushConstants.NoticeSubType.CAPTAIN_INVITATION_FEED);
        return feed;
    }

    /**
     * 构造申请入队的反馈消息
     * @param context
     * @param msg
     * @return
     */
    public static PushMessage getApplyTeamFeedMessage(Context context,PushMessage msg){
        User user = BmobUser.getCurrentUser(context, User.class);
        String teamName = null;
        String targetId = "";
        try{
            targetId = msg.getTargetId().split("&")[1];//给申请入队者发生入队反馈，其targetId为申请方的用户id
            teamName = msg.getTitle().split("&")[1];
        }catch(Exception exc){
            teamName = msg.getTitle();
        }
        String belongId = user.getUsername();//发送者的用户名
        String title = teamName;
        String alert = "恭喜您成功加入"+teamName;
        PushMessage feed = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,PushConstants.NoticeSubType.APPLY_TEAM_FEED);
        return feed;
    }

    /*
    * 重置已读
    * */
    public static  void resetMsgReaded(Context context,String objectId){
        PushMsg msg = new PushMsg();
        msg.setIsRead(1);
        msg.update(context,objectId,new UpdateListener() {
            @Override
            public void onSuccess() {
                Log.i("life", "消息已置为已读");
            }

            @Override
            public void onFailure(int i, String s) {
                Log.i("life","消息置为已读失败："+s);
            }
        });
    }

    /**
     * 构建比赛报告的消息对象
     * @return
     */
    public static PushMessage getReportMsg(boolean isHomeTeam,User targetUser,Tournament mTournament){
        String teamObjectId ="";
        String alert ="";
        String title = "";
        if(isHomeTeam){//当前是主队
            teamObjectId = mTournament.getHome_court().getObjectId();
            alert = TimeUtils.getCurrentMonthAndDay() + "与球队" + mTournament.getOpponent().getName() + "的比赛报告已生成";
            title = mTournament.getHome_court().getName();
        }else{//当前为客队
            teamObjectId = mTournament.getOpponent().getObjectId();
            title = mTournament.getOpponent().getName();
            alert = TimeUtils.getCurrentMonthAndDay() + "与球队" + mTournament.getHome_court().getName() + "的比赛报告已生成";
        }
        String belongId = targetUser.getUsername();//发送者的手机号
        String targetId = mTournament.getObjectId()+"&"+teamObjectId;
        //组装PushMessage对象
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.MATCH_REPORT);
        return msg;
    }

    /**
     * 构建比赛认证的消息对象
     * @param context：上下文
     * @param isHomeTeam:是否主队
     * @param isSuccess：认证状态
     * @param mTournament：联赛信息
     * @return
     */
    public static PushMessage getAuthMessage(Context context,boolean isHomeTeam,Object isSuccess,Tournament mTournament) {
        String alert = "";
        String title = "";
        String targetId = "";
        int subType;
        if (isHomeTeam) {//主队的话，发给主队队长
            if("0".equals(isSuccess)){
                alert = TimeUtils.getCurrentMonthAndDay() + "与球队" + mTournament.getOpponent().getName() + "的比赛结果认证失败";
                subType = PushConstants.NoticeSubType.GAME_AUTH_FAIL;
            }else{
                alert =  TimeUtils.getCurrentMonthAndDay()+"与球队"+mTournament.getOpponent().getName()+"的比赛结果已认证";
                subType = PushConstants.NoticeSubType.GAME_AUTH_SUCCESS;
            }
            title = mTournament.getHome_court().getName();
            targetId = mTournament.getObjectId() + "&" + mTournament.getHome_court().getObjectId();
        } else { //发给客队队长
            if("0".equals(isSuccess)){//未成功
                alert = TimeUtils.getCurrentMonthAndDay() + "与球队" + mTournament.getHome_court().getName() + "比赛结果认证失败";
                subType = PushConstants.NoticeSubType.GAME_AUTH_FAIL;
            }else{
                alert =  TimeUtils.getCurrentMonthAndDay()+"与球队"+mTournament.getHome_court().getName()+"的比赛结果已认证";
                subType = PushConstants.NoticeSubType.GAME_AUTH_SUCCESS;
            }
            title = mTournament.getOpponent().getName();
            targetId = mTournament.getObjectId() + "&" + mTournament.getOpponent().getObjectId();
        }
        String belongId = BmobUser.getCurrentUser(context, User.class).getUsername();
        //组装PushMessage对象
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,subType);
        return msg;
    }

    /**
     * 构建添加好友或好友的反馈信息
     * @param context
     * @return
     */
	public static PushMessage getAddFriendMessage(Context context,boolean isFeed){
        User user = BmobUser.getCurrentUser(context, User.class);
        String username = TextUtils.isEmpty(user.getNickname())?user.getUsername():user.getNickname();
        String alert = username + "添加您为好友";
        String belongId = user.getUsername();//发送者的userName
        String targetId = user.getObjectId();//用户的发送id
        String title = username;//一般为球队名或个人
        int subType = 0;
        if(isFeed){
            subType =PushConstants.NoticeSubType.ADD_FRIEND_FEED;
        }else{
            subType =PushConstants.NoticeSubType.ADD_FRIEND;
        }
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.PERSONAL,subType);
		return msg;
	}

    /**
	 * 构造踢出球队的消息
	 * @param context
	 * @param team
	 * @return
	 */
	public static PushMessage getKickTeamMessage(Context context,Team team){
        User cur = BmobUser.getCurrentUser(context,User.class);
        String alert = "您已经被移出"+team.getName();
        String belongId = cur.getUsername();//谁发送就填谁的手机号
        String targetId = null;
        String title = team.getName();//球队名
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.TEAM_KICKOUT);
		return msg;
	}

	/**
	 * 构造退出球队的消息
     * @param context
     * @param team
	 * @return
	 */
	public static PushMessage getQuitTeamMessage(Context context,Team team){
        User cur = BmobUser.getCurrentUser(context,User.class);
        String belongId = cur.getObjectId();
        String name = TextUtils.isEmpty(cur.getNickname())?cur.getUsername():cur.getNickname();
        String alert = name+"已经退出"+team.getName();
        String targetId = team.getObjectId();
        String title = name;
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.QUIT_TEAM);
		return msg;
	}
	
	/**
	 * 发布阵容的消息
	 * @param context
	 * @param currentTeam
	 * @return
	 */
	public static PushMessage lineupPublishMessage(Context context,Team currentTeam){
        User cur = BmobUser.getCurrentUser(context,User.class);
        String belongId = cur.getObjectId();
        String alert = currentTeam.getName() + "更新了首发阵容";
        String targetId = currentTeam.getObjectId();
        String title = currentTeam.getName();
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.LINEUP_PUBLISH);
		return msg;
	}

    /**
     * 当前队长向对方队长发送约赛的消息
     * @return
     */
    public static PushMessage createGame2Opponent(Context context,Tournament tour){
        Team home = tour.getHome_court();
        Team opponent =  tour.getOpponent();
        String name = tour.getName();
        //比赛日期
        String date = tour.getEvent_date().getDate();
        //比赛时间
        String startTime =tour.getStart_time().getDate();
        //比赛地点
        String site =tour.getSite();
        //比赛城市
        String city =tour.getCity();
        //某某球队
        String alert =home.getName()+"邀请你们"+TimeUtils.getCompetitionDate(tour.getEvent_date())+"在"+site+"比赛";
        User cur = BmobUser.getCurrentUser(context,User.class);
        String belongId =cur.getUsername();
        String title =opponent.getName();//客队名称
        String targetId= home.getObjectId()+"&"+opponent.getObjectId();//主队ID&客队ID
        JSONObject extra = new JSONObject();
        try{
            extra.put("site", site);
            extra.put("nature", TournamentHelper.NATURE_FRIENDSHIP);
            extra.put("name",name);
            extra.put("start_time", TimeUtils.getTime(startTime));
            extra.put("city",city);
            extra.put("home_court", home.getObjectId());
            extra.put("opponent", opponent.getObjectId());
            extra.put("event_date", date);
            extra.put("state", false);
        }catch(Exception e){
        }
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.CAPTAIN_CREATE_COMPE,extra.toString());
        return msg;
    }

    /*
    * 创建比赛的反馈信息给主队队长
    * */
    public static PushMessage createGameFeed2HomeCaption(Context context,String curTeamName){
        //当前用户为客队队长
        User user = BmobUser.getCurrentUser(context, User.class);
        String belongId = user.getUsername();//发送者的用户名
        String targetId = "";//可为空
        String title = curTeamName;
        String alert = curTeamName+"球队已经接收您的比赛邀请";
        PushMessage feed = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,PushConstants.NoticeSubType.CREATE_COMPE_FEED);
        return feed;
    }

    /*
    * 创建比赛的反馈信息给双方球队的球员
    * */
    public static PushMessage createGameFeed2All(Context context,boolean isMyTeam,Team home,Team opp,Tournament tour){
        //当前用户为客队队长
        User user = BmobUser.getCurrentUser(context, User.class);
        String belongId = user.getUsername();//发送者的用户名
        String title="";
        String teamId = "";
        if(isMyTeam){//是我的球队的话，那么用本球队的队名作为title,因为本球队是客队
            title = opp.getName();
            teamId = opp.getObjectId();
        }else{
            title = home.getName();
            teamId = home.getObjectId();
        }
        String targetId = tour.getObjectId()+"&"+teamId;
        String alert = "安排了一场新的比赛";
        PushMessage feed = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM,PushConstants.NoticeSubType.CREATE_COMPE);
        return feed;
    }

    /**
     * 本队球员创建比赛通知本球队队长
     * @param context
     * @param tour
     * @return
     */
    public static PushMessage createGame2MyCaptionByMember(Context context,Tournament tour){
        Team home = tour.getHome_court();
        Team opponent =  tour.getOpponent();
        //比赛名称
        String tourName = tour.getName();
        //比赛日期
        String date = tour.getEvent_date().getDate();
        //比赛时间
        String startTime =tour.getStart_time().getDate();
        //比赛地点
        String site =tour.getSite();
        //比赛城市
        String city =tour.getCity();

        User cur = BmobUser.getCurrentUser(context,User.class);
        String name = TextUtils.isEmpty(cur.getNickname())?cur.getUsername():cur.getNickname();
        String alert ="队友"+name+"申请"+TimeUtils.getCompetitionDate(tour.getEvent_date())+"与"+opponent.getName()+"在"+site+"比赛。";
        String belongId =cur.getUsername();
        String title =home.getName();//主队名称
        String targetId= home.getObjectId()+"&"+opponent.getObjectId();//主队ID&客队ID

        JSONObject extra = new JSONObject();
        try{
            extra.put("site", site);
            extra.put("nature", TournamentHelper.NATURE_FRIENDSHIP);
            extra.put("name",tourName);
            extra.put("start_time", TimeUtils.getTime(startTime));
            extra.put("city",city);
            extra.put("home_court", home.getObjectId());
            extra.put("opponent", opponent.getObjectId());
            extra.put("event_date", date);
            extra.put("state", false);
        }catch(Exception e){
        }
        PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.MENBER_CREATE_COMPE,extra.toString());
        return msg;
    }

     /*
     * 队长处理本队队员的创建比赛的请求
     * */
    public static void dealCreateGameFromMember(Context context,String extra){
        String homeName="";
        String oppTeamName="";
        String site="";
        String homeId="";
        String opponentId="";
        BmobDate event_date=null;
        try {
            JSONObject extraObj = new JSONObject(extra);
            site = extraObj.getString("site");
            String name = extraObj.getString("name");
            homeName= name.split("-")[0];//主队名
            oppTeamName = name.split("-")[1];//客队名
            homeId = extraObj.getString("home_court");//主队id
            opponentId = extraObj.getString("opponent");//客队id
            //比赛日期
            event_date = new BmobDate(TimeUtils.getDateByString2(Long.parseLong(extraObj.optString("event_date")) * 1000));
        }catch(Exception ex){
        }
        String alert =homeName+"邀请你们"+TimeUtils.getCompetitionDate(event_date)+"在"+site+"比赛";
        User cur = BmobUser.getCurrentUser(context,User.class);
        String belongId =cur.getUsername();
        String title =oppTeamName;//客队名称
        String targetId= homeId+"&"+opponentId;//主队ID&客队ID
        final PushMessage msg = new PushMessage(alert, belongId, targetId, title, PushConstants.NoticeType.TEAM, PushConstants.NoticeSubType.CAPTAIN_CREATE_COMPE,extra);
        //查询出主队队长的信息，并给队长发送消息
        TeamManager.findTeamByObjectId(context, homeId, new GetListener<Team>() {

            @Override
            public void onFailure(int arg0, String arg1) {
                // TODO Auto-generated method stub
                LogUtil.i("life","查询主队队长信息失败："+arg0+"-"+arg1);
            }

            @Override
            public void onSuccess(Team arg0) {
                // TODO Auto-generated method stub
                if(arg0!=null){
                    MyApplication.getInstance().getPushHelper2().push2User(arg0.getCaptain(),msg);
                }
            }
        });
    }
}
