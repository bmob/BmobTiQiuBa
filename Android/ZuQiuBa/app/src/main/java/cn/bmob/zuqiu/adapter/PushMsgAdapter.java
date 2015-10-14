package cn.bmob.zuqiu.adapter;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.db.BmobDB;
import cn.bmob.zuqiu.ui.AuthFailActivity;
import cn.bmob.zuqiu.ui.CompetitionInfoActivity;
import cn.bmob.zuqiu.ui.LeagueDetailActivity;
import cn.bmob.zuqiu.ui.LineupActivity;
import cn.bmob.zuqiu.ui.PersonalInfoActivity;
import cn.bmob.zuqiu.ui.ViewGroupExample;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushConstants;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiu.utils.TournamentHelper;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.PushMsg;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class PushMsgAdapter extends BaseAdapter{

	private Context mContext;
	private List<PushMessage> data = new ArrayList<PushMessage>();
	
	public PushMsgAdapter(Context mContext, List<PushMessage> data) {
		super();
		this.mContext = mContext;
		this.data = data;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return data.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return data.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		ViewHolder viewHolder = null;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_msg, null);
			viewHolder.msgType = (TextView)convertView.findViewById(R.id.msg_type);
			viewHolder.msgTime = (TextView)convertView.findViewById(R.id.msg_time);
			viewHolder.msgTitle = (TextView)convertView.findViewById(R.id.msg_title);
			viewHolder.msgDesc= (TextView)convertView.findViewById(R.id.msg_desc);
			viewHolder.msgOperate = (Button)convertView.findViewById(R.id.msg_operate);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		final PushMessage msg = data.get(position);
		switch (msg.getType()) {
		case PushConstants.NoticeType.PERSONAL:
			viewHolder.msgType.setText("个人消息");
			viewHolder.msgType.setCompoundDrawablesWithIntrinsicBounds(R.drawable.icon_msg_type_personal, 0, 0, 0);
			if(msg.getStatus()==0){
				switch (msg.getSubtype()) {
				case PushConstants.NoticeSubType.ADD_FRIEND:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("查看");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.ADD_FRIEND_FEED:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("确定");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				}
				
			}else{
				switch (msg.getSubtype()) {
				case PushConstants.NoticeSubType.ADD_FRIEND:
					viewHolder.msgOperate.setEnabled(false);
					viewHolder.msgOperate.setText("已处理");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.ADD_FRIEND_FEED:
					viewHolder.msgOperate.setEnabled(false);
					viewHolder.msgOperate.setText("知道了");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				}
			}
			break;
		case PushConstants.NoticeType.TEAM:
			viewHolder.msgType.setText("球队消息");
			viewHolder.msgType.setCompoundDrawablesWithIntrinsicBounds(R.drawable.icon_msg_type_team, 0, 0, 0);
			if(msg.getStatus()==0){
				switch (msg.getSubtype()) {
				case PushConstants.NoticeSubType.APPLY_TEAM:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("同意");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.APPLY_TEAM_FEED:
                    // 申请入队的反馈
                    viewHolder.msgOperate.setVisibility(View.GONE);
					break;
				case PushConstants.NoticeSubType.CAPTAIN_INVITATION:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("同意");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.CAPTAIN_INVITATION_FEED:
                    viewHolder.msgOperate.setVisibility(View.GONE);
					break;
				case PushConstants.NoticeSubType.MEMBER_INVITATION:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("同意");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.MEMBER_INVITATION_FEED:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("确定");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.TEAM_KICKOUT:
					viewHolder.msgOperate.setVisibility(View.GONE);
					break;
				case PushConstants.NoticeSubType.QUIT_TEAM:
					viewHolder.msgOperate.setVisibility(View.GONE);
					break;
				case PushConstants.NoticeSubType.LINEUP_PUBLISH:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("查看");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.MATCH_REPORT:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("查看");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
                case PushConstants.NoticeSubType.GAME_AUTH_FAIL:
                case PushConstants.NoticeSubType.GAME_AUTH_SUCCESS:
                    // 比赛认证失败、成功
                    viewHolder.msgOperate.setEnabled(true);
                    viewHolder.msgOperate.setText("查看");
                    viewHolder.msgOperate.setVisibility(View.VISIBLE);
                    break;
                case PushConstants.NoticeSubType.CAPTAIN_CREATE_COMPE://队长创建比赛
                    viewHolder.msgOperate.setEnabled(true);
                    viewHolder.msgOperate.setText("同意");
                    viewHolder.msgOperate.setVisibility(View.VISIBLE);
                    break;
                case PushConstants.NoticeSubType.CREATE_COMPE_FEED:
                    viewHolder.msgOperate.setVisibility(View.GONE);
                break;
                case PushConstants.NoticeSubType.CREATE_COMPE:
                    // 创建比赛、创建比赛反馈
                    viewHolder.msgOperate.setEnabled(true);
                    viewHolder.msgOperate.setText("查看");
                    viewHolder.msgOperate.setVisibility(View.VISIBLE);
                break;
                }
				
			}else{
				switch (msg.getSubtype()) {
				case PushConstants.NoticeSubType.APPLY_TEAM:
					viewHolder.msgOperate.setEnabled(false);
					viewHolder.msgOperate.setText("已处理");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.APPLY_TEAM_FEED:
                    viewHolder.msgOperate.setVisibility(View.GONE);
//                    viewHolder.msgOperate.setEnabled(false);
//                    viewHolder.msgOperate.setVisibility(View.VISIBLE);
//                    viewHolder.msgOperate.setText("知道了");
					break;
				case PushConstants.NoticeSubType.CAPTAIN_INVITATION:
					viewHolder.msgOperate.setEnabled(false);
					viewHolder.msgOperate.setText("已处理");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.CAPTAIN_INVITATION_FEED:
//					viewHolder.msgOperate.setEnabled(false);
//					viewHolder.msgOperate.setText("知道了");
//					viewHolder.msgOperate.setVisibility(View.VISIBLE);
                    viewHolder.msgOperate.setVisibility(View.GONE);
					break;
				case PushConstants.NoticeSubType.MEMBER_INVITATION:
					viewHolder.msgOperate.setEnabled(false);
					viewHolder.msgOperate.setText("已处理");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.MEMBER_INVITATION_FEED:
					viewHolder.msgOperate.setEnabled(false);
					viewHolder.msgOperate.setText("知道了");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.TEAM_KICKOUT:
					viewHolder.msgOperate.setVisibility(View.GONE);
					break;
				case PushConstants.NoticeSubType.QUIT_TEAM:
					viewHolder.msgOperate.setVisibility(View.GONE);
					break;
				case PushConstants.NoticeSubType.LINEUP_PUBLISH:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("查看");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
				case PushConstants.NoticeSubType.MATCH_REPORT:
					viewHolder.msgOperate.setEnabled(true);
					viewHolder.msgOperate.setText("查看");
					viewHolder.msgOperate.setVisibility(View.VISIBLE);
					break;
                case PushConstants.NoticeSubType.CAPTAIN_CREATE_COMPE:
                    viewHolder.msgOperate.setEnabled(false);
                    viewHolder.msgOperate.setText("已处理");
                    viewHolder.msgOperate.setVisibility(View.VISIBLE);
                    break;
                case PushConstants.NoticeSubType.CREATE_COMPE_FEED://创建比赛的反馈
                    viewHolder.msgOperate.setVisibility(View.GONE);
                    break;
                case PushConstants.NoticeSubType.CREATE_COMPE://发给双方球队的球员的消息
                    viewHolder.msgOperate.setEnabled(true);
                    viewHolder.msgOperate.setText("查看");
                    viewHolder.msgOperate.setVisibility(View.VISIBLE);
                    break;
				}
			}
			break;
		case PushConstants.NoticeType.RANKING:
			viewHolder.msgType.setText("赛事消息");
			viewHolder.msgType.setCompoundDrawablesWithIntrinsicBounds(R.drawable.icon_msg_type_tournent, 0, 0, 0);
			if(msg.getStatus()==0){
				viewHolder.msgOperate.setEnabled(true);
				viewHolder.msgOperate.setText("查看");
			}else{
				viewHolder.msgOperate.setEnabled(false);
				viewHolder.msgOperate.setText("已处理");
			}
			break;
        case PushConstants.NoticeType.LEAGUE://联赛消息
            if(msg.getStatus()==0){
                switch (msg.getSubtype()) {
                    case PushConstants.NoticeSubType.LEAGUE_INVITE://邀请加入联赛
                        viewHolder.msgOperate.setVisibility(View.INVISIBLE);
                        break;
                    case PushConstants.NoticeSubType.LEAGUE_PUBLISH://发布联赛
                        viewHolder.msgOperate.setEnabled(true);
                        viewHolder.msgOperate.setText("查看");
                        viewHolder.msgOperate.setVisibility(View.VISIBLE);
                        break;
                    case PushConstants.NoticeSubType.LEAGUE_UPDATE://更新数据
                        viewHolder.msgOperate.setEnabled(true);
                        viewHolder.msgOperate.setText("查看");
                        viewHolder.msgOperate.setVisibility(View.VISIBLE);
                        break;
                }
            }else{
                switch (msg.getSubtype()) {
                    case PushConstants.NoticeSubType.LEAGUE_INVITE://邀请加入联赛
                        viewHolder.msgOperate.setVisibility(View.INVISIBLE);
                        break;
                    case PushConstants.NoticeSubType.LEAGUE_PUBLISH://发布联赛
                        viewHolder.msgOperate.setEnabled(false);
                        viewHolder.msgOperate.setText("已处理");
                        viewHolder.msgOperate.setVisibility(View.VISIBLE);
                        break;
                    case PushConstants.NoticeSubType.LEAGUE_UPDATE://更新数据
                        viewHolder.msgOperate.setEnabled(false);
                        viewHolder.msgOperate.setText("已处理");
                        viewHolder.msgOperate.setVisibility(View.VISIBLE);
                        break;
                }
            }
            break;
		}

		viewHolder.msgTime.setText(TimeUtils.getTimeByLong(msg.getTime()*1000));
        if(msg.getSubtype()==PushConstants.NoticeSubType.MEMBER_INVITATION||msg.getSubtype()==PushConstants.NoticeSubType.APPLY_TEAM){
            try{
                viewHolder.msgTitle.setText(msg.getTitle().split("&")[0]);
            }catch(Exception exc){
                viewHolder.msgTitle.setText(msg.getTitle());
            }
        }else{
            viewHolder.msgTitle.setText(msg.getTitle());
        }
        viewHolder.msgDesc.setText(msg.getAps().getAlert());
		viewHolder.msgOperate.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
                //改变本地的消息状态
                BmobDB.create(mContext).update(msg.get_id(), 1);
                msg.setStatus(1);
                notifyDataSetChanged();

                switch (msg.getSubtype()) {
                    case PushConstants.NoticeSubType.ADD_FRIEND://添加好友的同意按钮，点击同意后就添加对方为好友，并且发送反馈给发送者
                    //个人中心
                    Intent it = new Intent(mContext, PersonalInfoActivity.class);
                    User u = new User();
                    u.setNickname(msg.getTitle());
                    u.setObjectId(msg.getTargetId());
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("user", u);
                    it.putExtra("data", bundle);
                    it.putExtra("type","msg");//表明来自消息页面，需要发送添加好友的反馈
                    mContext.startActivity(it);
                    break;
                case PushConstants.NoticeSubType.ADD_FRIEND_FEED://好友反馈

                    break;
                case PushConstants.NoticeSubType.APPLY_TEAM://申请入队,需要同意入队的申请
					TeamManager.agreeApplyInToTheTeam(mContext, msg);
					break;
				case PushConstants.NoticeSubType.APPLY_TEAM_FEED://队长同意后就可以进入到本人的个人中心页面
					break;
				case PushConstants.NoticeSubType.CAPTAIN_INVITATION://邀请入队
                    // 甜菜邀请您加入球队“21世纪”
                    if(MyApplication.getInstance().getTeams()!=null
                            && MyApplication.getInstance().getTeams().size()>=2){
                        ToastUtil.showToast(mContext, "对不起，每位球员最多只能加入两只球队");
                        return;
                    }
					TeamManager.agreeInviteIntoTheTeam(mContext, msg);
                    //
					break;
				case PushConstants.NoticeSubType.CAPTAIN_INVITATION_FEED:

					break;
				case PushConstants.NoticeSubType.MEMBER_INVITATION://队员邀请，队长接收到的
                    //查询出被邀请人的用户信息
                    BmobQuery<User> bq = new BmobQuery<User>();
                    bq.addWhereEqualTo("username", msg.getTargetId().split("&")[1]);
                    bq.findObjects(mContext, new FindListener<User>() {
                        @Override
                        public void onSuccess(List<User> users) {
                            if(users.size()>0){
                                //组装发送消息
                                PushMessage pm = PushMessageHelper.dealMemberInvite(mContext,msg);
                                // 发送给邀请人
                                MyApplication.getInstance().getPushHelper2().push2User(users.get(0),pm);
                            }
                        }

                        @Override
                        public void onError(int i, String s) {

                        }
                    });

					break;
				case PushConstants.NoticeSubType.MEMBER_INVITATION_FEED:

					break;
				case PushConstants.NoticeSubType.TEAM_KICKOUT:
					//无操作
					break;
				case PushConstants.NoticeSubType.QUIT_TEAM:
					
					break;
				case PushConstants.NoticeSubType.LINEUP_PUBLISH://更新了首发阵容-跳转到阵容页面
					//跳转到阵容界面
					initProgressDialog("正在加载数据，请稍等");
					TeamManager.findTeamByObjectId(mContext, msg.getTargetId(), new GetListener<Team>() {

						@Override
						public void onFailure(int arg0, String arg1) {
							// TODO Auto-generated method stub
							dismissDialog();
							ToastUtil.showToast(mContext, "请检查网络连接");
						}

						@Override
						public void onSuccess(Team arg0) {
							// TODO Auto-generated method stub
							dismissDialog();
							Intent in = new Intent();
							in.setClass(mContext, LineupActivity.class);
							in.putExtra("team", arg0);
							mContext.startActivity(in);
						}
					});
					
					break;
				case PushConstants.NoticeSubType.MATCH_REPORT://比赛报告
			    	Intent intent = new Intent(mContext,ViewGroupExample.class);
			    	intent.putExtra("msg", msg);
			    	mContext.startActivity(intent);
					break;
                case PushConstants.NoticeSubType.CREATE_COMPE_FEED://收到创建比赛反馈的，不处理

                    break;
                case PushConstants.NoticeSubType.CREATE_COMPE://收到"安排了一场新比赛"的消息是可以查看这场联赛信息的
                    Intent i = new Intent(mContext,CompetitionInfoActivity.class);
                    String tid =msg.getTargetId().split("&")[0];//
                    Tournament tour=new Tournament();
                    tour.setObjectId(tid);
                    i.putExtra("type","user");
                    i.putExtra("tournament", tour);//需要根据比赛id去重新查询
                    mContext.startActivity(i);
                    break;
                case PushConstants.NoticeSubType.CAPTAIN_CREATE_COMPE:
                     //对方约赛，同意的话由当前接收到该消息的用户（一般是客队队长）来创建比赛,并发送反馈信息给主队队长还有双方球对的所有球员
                    TournamentHelper.agressGameFromHome(mContext,msg);
                    break;
                case PushConstants.NoticeSubType.MENBER_CREATE_COMPE://队员创建比赛，一般是主队队长接收到本队队员发来的创建比赛的请求，队长接收到后，需要发送给指定的客队队长
                    //因为推送得到的消息里面是没有extra消息的，需要去查询PushMsg表，所以这里为两种情况
                    String extra =msg.getExtra();
                    if(TextUtils.isEmpty(extra)){//推送消息
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
                                    PushMessageHelper.dealCreateGameFromMember(mContext,extra);
                                }
                            }

                            @Override
                            public void onError(int i, String s) {
                                LogUtil.i("life", "查询指定ID的约赛消息失败：" + i + "-" + s);
                            }
                        });
                    }else{//从PushMsg表中取出来的消息
                        PushMessageHelper.dealCreateGameFromMember(mContext,extra);
                    }
                    break;
                case PushConstants.NoticeSubType.GAME_AUTH_FAIL:
                    Intent it1 = new Intent(mContext, AuthFailActivity.class);
                    String tourId= msg.getTargetId().split("&")[0];
                    it1.putExtra("tournamentId", tourId);
                    mContext.startActivity(it1);
                    break;
                case PushConstants.NoticeSubType.GAME_AUTH_SUCCESS:
                    Intent it2 = new Intent(mContext,ViewGroupExample.class);
                    it2.putExtra("msg", msg);
                    mContext.startActivity(it2);
                break;
                case PushConstants.NoticeSubType.LEAGUE_INVITE://联赛邀请

                    break;
                case PushConstants.NoticeSubType.LEAGUE_PUBLISH://联赛发布--去到联赛赛程页面
                    initProgressDialog("正在加载数据，请稍等");
                    new  CompetitionManager(mContext).getLeague(msg.getTargetId(),new FindListener<League>() {
                        @Override
                        public void onSuccess(List<League> leagues) {
                            dismissDialog();
                            if(leagues!=null&&leagues.size()>0){
                                Intent in = new Intent();
                                in.setClass(mContext, LeagueDetailActivity.class);
                                in.putExtra("league", leagues.get(0));
                                in.putExtra("page",3);//去到赛程页面
                                mContext.startActivity(in);
                            }else{
                                ToastUtil.showToast(mContext, "联赛信息查询失败...");
                            }
                        }

                        @Override
                        public void onError(int i, String s) {
                            dismissDialog();
                            ToastUtil.showToast(mContext, "请检查网络连接");
                        }
                    });
                break;
                case PushConstants.NoticeSubType.LEAGUE_UPDATE://联赛更新--去到联赛积分榜页面
                    //查询出当前的联赛信息
                    initProgressDialog("正在加载数据，请稍等");
                    new  CompetitionManager(mContext).getLeague(msg.getTargetId(),new FindListener<League>() {
                        @Override
                        public void onSuccess(List<League> leagues) {
                            dismissDialog();
                            if(leagues!=null&&leagues.size()>0){
                                Intent in = new Intent();
                                in.setClass(mContext, LeagueDetailActivity.class);
                                in.putExtra("league", leagues.get(0));
                                in.putExtra("page",0);//去到积分页面
                                mContext.startActivity(in);
                            }else{
                                ToastUtil.showToast(mContext, "联赛信息查询失败...");
                            }
                        }

                        @Override
                        public void onError(int i, String s) {
                            dismissDialog();
                            ToastUtil.showToast(mContext, "请检查网络连接");
                        }
                    });
                    break;
                    default:
					break;
				}
			}
		});
		return convertView;
	}

	public static class ViewHolder{
		public TextView msgType;
		public TextView msgTime;
		public TextView msgTitle;
		public TextView msgDesc;
		public Button msgOperate;
	}
	
	ProgressDialog progressDialog;
	protected void initProgressDialog(String loading) {
		if(progressDialog==null){
			progressDialog = new ProgressDialog(mContext);
		}
		progressDialog.setMessage(loading);
		progressDialog.show();
	}

	protected void dismissDialog(){
		if(progressDialog!=null){
			progressDialog.dismiss();
		}
	}
}
