package cn.bmob.zuqiu.utils;

import android.content.Context;
import android.text.TextUtils;

import org.json.JSONObject;

import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.PushMsg;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

/**
 * 赛事助手类，负责与赛事相关的一些公共逻辑
 * @author venus
 *
 */
public class TournamentHelper {

    /**
     * 小组赛
     */
    public static final int NATURE_GROUP = 1;
    /**
     * 淘汰赛
     */
    public static final int NATURE_OUT = 2;
    /**
     * 友谊赛
     */
    public static final int NATURE_FRIENDSHIP = 3;
	
	/*
	 * 获取比赛性质
	 */
	public static String getNature(int nature){
		String natureStr;
		switch (nature) {
		case 1:
			natureStr = "小组赛";
			break;
		case 2:
			natureStr = "淘汰赛";
			break;
		case 3:
			natureStr = "友谊赛";
			break;
		default:
            natureStr = "友谊赛";
			break;
		}
		return natureStr;
	}

    public interface NewSaveListener{
        public void onSuccess(Tournament tour);
        public void onError(int code ,String msg);
    }

    /*
    * 同意来自主队队长的约赛
    * */
    public static void agressGameFromHome(final Context mContext,PushMessage msg){
        //                   以下是PushMsg表中的extra字段中的内容，它里面同样包含一个extra字段
//                {
//                    title: "21世纪",
//                    time: 1430187624,
//                    flag: "notice",
//                    aps: {
//                    alert: "21世纪球队邀请您的球队参加比赛",
//                    badge: 0
//                    },
//                    status: 0,
//                    extra: {
//                            site: "大学城",
//                            opponent: "08ed5c6b55",
//                            nature: 3,
//                            event_date: "1430150400",
//                            name: "21世纪-车仔",
//                            state: false,
//                            start_time: "1430191140",
//                            home_court: "093dc7adf2",
//                            city: "440100"
//                    },
//                    belongId: "18620050227",
//                    subtype: 15,
//                    targetId: "093dc7adf2&08ed5c6b55",
//                    type: 2
//                }
        // 客队队长收到主队队长发来的约赛消息，此时分两种情况，
        //  一、接收到的是推送消息，但是推送消息里面是没有extra字段（包含这场比赛的一些信息），因此需要直接从PushMsg表中查询出该条消息出来。
        //  二、通过pull查询表的方式获取到的消息，此时msg里面有extra字段
        String extra = msg.getExtra();
        if(TextUtils.isEmpty(extra)){//代表的是推送消息,此时需要查询出extra字段
            BmobQuery<PushMsg> query = new BmobQuery<PushMsg>();
            query.addWhereEqualTo("objectId",msg.getObjectId());
            query.setLimit(1);
            query.findObjects(mContext,new FindListener<PushMsg>() {
                @Override
                public void onSuccess(final List<PushMsg> pushMsgs) {
                    if(pushMsgs!=null && pushMsgs.size()>0){
                        PushMsg msg = pushMsgs.get(0);
                        PushMessage push = new PushMessage(msg);
                        String extra =  push.getExtra();//这个真正的extra字段
                        parseExtra(mContext,extra);
                    }
                }

                @Override
                public void onError(int i, String s) {
                    LogUtil.i("life","查询指定ID的约赛消息失败："+i+"-"+s);
                }
            });
        }else{
            parseExtra(mContext,extra);
        }

    }

    public static void parseExtra(final Context context ,String extra){
        try{
            JSONObject extraObj = new JSONObject(extra);
            String site = extraObj.getString("site");
            String city = extraObj.getString("city");
            int nature = extraObj.getInt("nature");
            String name = extraObj.getString("name");
            final String homeName =name.split("-")[0];//主队名
            final String oppTeamName = name.split("-")[1];//客队名
            final String homeId = extraObj.getString("home_court");//主队id
            String opponentId = extraObj.getString("opponent");//客队id
            boolean state =extraObj.optBoolean("state", false);
            //比赛日期
            BmobDate event_date = new BmobDate(TimeUtils.getDateByString2(Long.parseLong(extraObj.optString("event_date"))*1000));
            //开始时间
            BmobDate start_time = new BmobDate(TimeUtils.getDateByString2(Long.parseLong(extraObj.optString("start_time"))*1000));
            //创建比赛
            final Tournament tour= new Tournament();
            tour.setName(name);
            tour.setCity(city);
            tour.setStart_time(start_time);
            tour.setState(state);
            tour.setNature(nature);
            tour.setSite(site);
            tour.setEvent_date(event_date);

            final Team homeCourt = new Team();
            homeCourt.setObjectId(homeId);
            homeCourt.setName(homeName);
            tour.setHome_court(homeCourt);
            final Team oppnent = new Team();
            oppnent.setObjectId(opponentId);
            oppnent.setName(oppTeamName);
            tour.setOpponent(oppnent);
            tour.save(context,new SaveListener() {
                @Override
                public void onSuccess() {
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
                                PushMessage push = PushMessageHelper.createGameFeed2HomeCaption(context,oppnent.getName());
                                MyApplication.getInstance().getPushHelper2().push2User(arg0.getCaptain(),push);
                            }
                        }
                    });
                    //给双方球队的所有球员发送消息
                    //给主队的队员发
                    TeamManager.getMember(context,homeCourt,new FindListener<User>() {
                        @Override
                        public void onSuccess(List<User> users) {
                            if(users!=null && users.size()>0){
                                int s = users.size();
                                for(int i =0;i<s;i++){
                                    PushMessage push = PushMessageHelper.createGameFeed2All(context,false,homeCourt,oppnent,tour);
                                    MyApplication.getInstance().getPushHelper2().push2User(users.get(i),push);
                                }
                            }
                        }

                        @Override
                        public void onError(int i, String s) {
                            LogUtil.i("life","查询主队所有球员信息失败："+i+"-"+s);
                        }
                    });

                    //给客队的队员发
                    TeamManager.getMember(context,oppnent,new FindListener<User>() {
                        @Override
                        public void onSuccess(List<User> users) {
                            if(users!=null && users.size()>0){
                                int s = users.size();
                                for(int i =0;i<s;i++){
                                    PushMessage push = PushMessageHelper.createGameFeed2All(context,true,homeCourt,oppnent,tour);
                                    MyApplication.getInstance().getPushHelper2().push2User(users.get(i),push);
                                }
                            }
                        }

                        @Override
                        public void onError(int i, String s) {
                            LogUtil.i("life","查询客队所有球员信息失败："+i+"-"+s);
                        }
                    });

                }

                @Override
                public void onFailure(int i, String s) {
                    LogUtil.i("life","保存联赛信息失败："+i+"-"+s);
                }
            });
        }catch(Exception ex){
        }
    }
}
