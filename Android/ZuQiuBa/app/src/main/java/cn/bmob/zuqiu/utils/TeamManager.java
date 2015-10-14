package cn.bmob.zuqiu.utils;


import android.content.Context;

import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.datatype.BmobRelation;
import cn.bmob.v3.listener.DeleteListener;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class TeamManager {
	
	public static final String TAG = "TeamManager";

    public static void deleteTeam(Context context,Team team,DeleteListener listener){
        Team t = new Team();
        t.delete(context,team.getObjectId(),listener);
    }

	public static void deleteMember(Context mContext,Team team,User user,UpdateListener listener){
		if(team==null||user==null){
			return;
		}
		BmobRelation re = new BmobRelation();
		re.remove(user);
		team.setFootballer(re);
		team.update(mContext, listener);
	}
	
	public static void changeCaptain(Context mContext,Team team,User captain,UpdateListener listener){
		if(team==null||captain==null){
			return;
		}
		team.setCaptain(captain);
		team.update(mContext, listener);
	}
	
	public static void getMember(Context mContext,Team team,FindListener<User> listener){
		if(team==null){
			return;
		}
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo("footballer", new BmobPointer(team));
		query.findObjects(mContext,listener);
	}

	/**
	 * 判断用户是否为球队队长
	 * 用于：1.修改球队资料（球队资料和成员管理只有队长可见。）
	 * 		2.修改阵容
	 * 		3.修改比赛比分，队员比分
	 * @param team
	 * @param user
	 * @return
	 */
	public static boolean isCaptain(Team team,User user){
		if(team==null||user==null){
			return false;
		}
		if(team.getCaptain()!=null&&team.getCaptain().getObjectId().equals(user.getObjectId())){
			return true;
		}
		return false;
	}
	
	public static void getMyTeams(Context context,FindListener<Team> listener){
		User user = BmobUser.getCurrentUser(context, User.class);
		BmobQuery<Team> query = new BmobQuery<Team>();
		BmobQuery<User> users = new BmobQuery<User>();
		users.addWhereEqualTo("objectId", user.getObjectId());
		query.include("captain,lineup");
		query.addWhereMatchesQuery("footballer", "_User", users);
		query.findObjects(context, listener);
	}
	
	public static void getTeams(Context context,User user,FindListener<Team> listener){
		BmobQuery<Team> query = new BmobQuery<Team>();
		BmobQuery<User> users = new BmobQuery<User>();
		users.addWhereEqualTo("objectId", user.getObjectId());
		query.include("captain,lineup");
		query.addWhereMatchesQuery("footballer", "_User", users);
		query.findObjects(context, listener);
	}
	
	
	public static void findTeamByObjectId(Context context,String objectId,GetListener<Team> listener){
		if(objectId == null){
			LogUtil.e(TAG,"球队id为空");
			return;
		}
		BmobQuery<Team> query = new BmobQuery<Team>();
		query.include("captain,lineup");
		query.getObject(context, objectId, listener);
	}

    /**
     * 同意队长的邀请加入战队的请求
     * 此操作是别人邀请你入队时执行的，比如某队长邀请您加入他的球队xxx，收到消息后点击同意就执行此方法
     * @param mContext
     * @param msg
     */
    public static void agreeInviteIntoTheTeam(final Context mContext,final PushMessage msg){
        User user = BmobUser.getCurrentUser(mContext, User.class);
        BmobRelation relation = new BmobRelation();
        relation.add(user);
        final Team team = new Team();
        team.setObjectId(msg.getTargetId());
        team.setFootballer(relation);
        team.update(mContext, new UpdateListener() {

            @Override
            public void onSuccess() {
                ToastUtil.showToast(mContext, "成功加入该球队");
                // 给球队每位成员发送一条新成员加入的消息
                //获取指定球队的所有队员
                getMember(mContext,team,new FindListener<User>() {
                    @Override
                    public void onSuccess(List<User> users) {
                        if(users!=null && users.size()>0){
                            int size = users.size();
                            for(int i=0;i<size;i++){
                                final PushMessage newMsg = PushMessageHelper.getNewMemberMsgByInvite(mContext,msg);
                                MyApplication.getInstance().getPushHelper2().push2User(users.get(i),newMsg);
                            }
                        }
                    }
                    @Override
                    public void onError(int i, String s) {
                        LogUtil.i("push","获取球队所有的成员信息失败...");
                    }
                });

                BmobQuery<Team> query = new BmobQuery<Team>();
                query.include("captain,lineup");
                query.getObject(mContext, team.getObjectId(),new GetListener<Team>() {
                    @Override
                    public void onSuccess(Team team) {
                        if(team!=null){
                            //本地保存战队
                            MyApplication.getInstance().getTeams().add(team);
                            //通知队长，你已同意加入球队
                            final PushMessage feedMsg = PushMessageHelper.getInviteFeedMessage(mContext,msg);
                            MyApplication.getInstance().getPushHelper2().push2User(team.getCaptain(),feedMsg);
                        }
                    }

                    @Override
                    public void onFailure(int i, String s) {
                        LogUtil.i("push","创建队长邀请入队的反馈信息后获取队长的信息失败...");

                    }
                });
            }

            @Override
            public void onFailure(int i, String s) {
                ToastUtil.showToast(mContext, "加入球队失败");
            }
        });
    }


    /**
     * 同意申请入队的操作
     * 通常这种操作是队长执行的，比如xx人申请加入xx队，队长收到消息后点击同意按钮就是执行此方法
     * @param mContext
     * @param msg 收到的消息内容
     */
    public static void agreeApplyInToTheTeam(final Context mContext,final PushMessage msg){
        // targetId的内容格式为"球队Id&球员Id"
        String teamObjectId = msg.getTargetId().split("&")[0];
        final String userObjectId = msg.getTargetId().split("&")[1];
        User user = new User();
        user.setObjectId(userObjectId);
        BmobRelation relation = new BmobRelation();
        relation.add(user);
        final Team team = new Team();
        team.setObjectId(teamObjectId);
        team.setFootballer(relation);
        team.update(mContext, new UpdateListener() {
            @Override
            public void onSuccess() {
                ToastUtil.showToast(mContext, "已将该球员加入队伍中");
                // 给球队每位成员发送一条新成员加入的消息
                //获取指定球队的所有队员
                getMember(mContext,team,new FindListener<User>() {
                    @Override
                    public void onSuccess(List<User> users) {
                        if(users!=null && users.size()>0){
                            int size = users.size();
                            for(int i=0;i<size;i++){
                                final PushMessage newMsg = PushMessageHelper.getNewMemberMsgByApply(mContext,msg);
                                MyApplication.getInstance().getPushHelper2().push2User(users.get(i),newMsg);
                            }
                        }
                    }

                    @Override
                    public void onError(int i, String s) {
                        LogUtil.i("push","获取球队所有的成员信息失败...");
                    }
                });

                //给指定的申请方发生同意请求
                final PushMessage feedMsg = PushMessageHelper.getApplyTeamFeedMessage(mContext,msg);
                BmobQuery<User> q = new BmobQuery<User>();
                q.getObject(mContext, userObjectId, new GetListener<User>() {
                    @Override
                    public void onSuccess(User user) {
                        LogUtil.d("push","该用户信息的pushUserId为:"+user.getPushUserId());
                        // 通知对方可以加入球队
                        MyApplication.getInstance().getPushHelper2().push2User(user,feedMsg);
                    }

                    @Override
                    public void onFailure(int i, String s) {
                        LogUtil.i("push","创建申请入队的反馈信息后获取指定用户的信息失败...");
                    }
                });

            }

            @Override
            public void onFailure(int i, String s) {
                ToastUtil.showToast(mContext, "未能成功将该球员加入到队伍中");
            }
        });
    }

//    /*
//    * */
//    public static  void checkTeamScore(Context context,Tournament tour,Team myTeam){
//        BmobQuery<TeamScore> query =new BmobQuery<TeamScore>();
//        query.addWhereEqualTo("competition",tour);
//        query.addWhereEqualTo("team",myTeam);
//        query.setLimit(1);
//        query.findObjects(context,new FindListener<TeamScore>() {
//            @Override
//            public void onSuccess(List<TeamScore> teamScores) {
//                if(teamScores!=null && teamScores.size()>0){
//
//                }
//            }
//
//            @Override
//            public void onError(int i, String s) {
//
//            }
//        });
//    }
}
