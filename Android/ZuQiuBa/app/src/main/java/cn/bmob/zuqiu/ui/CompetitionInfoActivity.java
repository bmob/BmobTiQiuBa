package cn.bmob.zuqiu.ui;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.CloudCodeListener;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.PersonalArgureAdapter;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.CloudCode;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.SharePreferenceUtil;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.TournamentHelper;
import cn.bmob.zuqiu.view.views.ScrollerNumberPicker;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.TeamScore;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;
/**
 * 赛事积分信息（点战绩表进入）
 * */
public class CompetitionInfoActivity extends BaseActivity implements SwipeRefreshLayout.OnRefreshListener {

	private ListView zdPlayerScoreList,kdPlayerScoreList;
	private PersonalArgureAdapter mZdPlayerScoreAdapter, mKdPlayerScoreAdapter;
	private List<PlayerScore> data;
	private List<PlayerScore> primaryData;
	private User user;
	
	private TextView cpTime;
	private TextView cpSite;
	private TextView cpNature;
	
	private TextView homeTeamPoint;
	private TextView homeTeamName;
	
	private TextView opponentTeamPoint;
	private TextView opponentTeamName;
	
	private TextView vsLineupHome;
	private TextView vsLineupOpponent;
	
	private TextView myName;
	private ImageView shotPrice;
	private ImageView passPrice;
	
	private TextView myShot;
	private TextView myPass;
	private TextView myAvg;
	
	private Button attend;
	
	private ImageView myShare;
	
	private Tournament mTournament;
	
//	private int myShotBall;
//	private int myPassBall;
	private float myAvgBall;
	private List<Team> myTeam = new ArrayList<Team>();

	private PlayerScore myScore;
    private SwipeRefreshLayout swipeLayout;
    SharePreferenceUtil spfu;
	
	@Override
	protected void onCreate(Bundle bundle) {
        // TODO Auto-generated method stub
        super.onCreate(bundle);
        setViewContent(R.layout.activity_competition_info);
        setUpAction(mActionBarTitle, "比赛", 0, View.VISIBLE);
        spfu = new SharePreferenceUtil(this);
        if(spfu.isFirstCompetitionInfo()){
            findViewById(R.id.rl_ydy1).setVisibility(View.VISIBLE);
            findViewById(R.id.rl_ydy2).setVisibility(View.VISIBLE);
            // 显示一次后设置第一次启动为false
            spfu.setFirstCompetitionInfo(false);
        }
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
        myTeam = MyApplication.getInstance().getTeams();
        user = BmobUser.getCurrentUser(mContext, User.class);
        Tournament  tour = (Tournament) getIntent().getSerializableExtra("tournament");
        String type = getIntent().getStringExtra("type");
        if(type!=null && type.equals("user")){//如果是个人战绩页面进来的，则需要重新查询一下Tourment,因此此时Tourment里面未包含主客队的队长信息
            queryTourment(tour.getObjectId());
        }else{
            mTournament = tour;
            //初始化赛事信息
            initTournament(mTournament);
        }
        swipeLayout = (SwipeRefreshLayout) this.findViewById(R.id.swipe_refresh);
        swipeLayout.setOnRefreshListener(this);
        // 顶部刷新的样式
        swipeLayout.setColorScheme(R.color.red_light,
                R.color.green_light,
                R.color.blue_bright,
                R.color.orange_light);
        zdPlayerScoreList.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                    int position, long id) {
                // TODO Auto-generated method stub
//					showEditDialog(data.get(position));
            }
        });
        homeTeamPoint.setOnClickListener(this);
        opponentTeamPoint.setOnClickListener(this);
        vsLineupHome.setOnClickListener(this);
        vsLineupOpponent.setOnClickListener(this);
        homeTeamName.setOnClickListener(this);
        opponentTeamName.setOnClickListener(this);
        myPass.setOnClickListener(this);
        myShot.setOnClickListener(this);
        myAvg.setOnClickListener(this);
        myShare.setOnClickListener(this);
        attend.setOnClickListener(this);
        attend.setTag(false);// 默认未登场
        findViewById(R.id.iv_i_know).setOnClickListener(this);
	}

    /*
    * 查询指定赛事信息
    * */
    private void queryTourment(String objectId){
        BmobQuery<Tournament> query = new BmobQuery<Tournament>();
        query.include("league,home_court,opponent,opponent.captain,home_court.captain");
        query.getObject(this,objectId,new GetListener<Tournament>() {
            @Override
            public void onSuccess(Tournament tournament) {
                if(tournament!=null){
                   mTournament = tournament;
                    initTournament(mTournament);
                }
            }

            @Override
            public void onFailure(int i, String s) {
                showToast("赛事信息查询失败");
            }
        });
    }
    /*
    * 获取该球员在该场比赛中的积分信息
    * */
    private void getScoreInfo(){
        getPersonalScore(new FindListener<PlayerScore>() {

            @Override
            public void onError(int arg0, String arg1) {
                // TODO Auto-generated method stub
                showToast("请检查网络");
            }

            @Override
            public void onSuccess(List<PlayerScore> arg0) {
                // TODO Auto-generated method stub
                if(arg0!=null&&arg0.size()>0){
                    myScore = arg0.get(0);
                    initMyScoreLayout(arg0.get(0));
                }else{
                    initMyScoreLayout(null);
                    LogUtil.i(TAG,"没有该球员在该场比赛的积分信息");
                }
            }
        });
        getMyTeamPlayerScore();//调试列表 点击事件无数据是注释
        getKdPlayerScore();
    }
	
	/**
	 * 初始化本场比赛信息
	 * @param tournament
	 */
	private void initTournament(Tournament tournament){
		if(tournament==null){
			return;
		}
		setUpAction(mActionBarTitle, tournament.getName(), 0, View.VISIBLE);
		cpTime.setText(TimeUtils.getTimeByBmobDate(tournament.getEvent_date()));
		if(!TextUtils.isEmpty(tournament.getSite())){
			cpSite.setText(tournament.getSite());
		}
		cpNature.setText(TournamentHelper.getNature(tournament.getNature()));
		homeTeamName.setText(tournament.getHome_court().getName());
		for(int i=0;i<myTeam.size();i++){
            if(myTeam.get(i).getObjectId().equals(tournament.getHome_court().getObjectId())){
				if(TextUtils.isEmpty(tournament.getScore_h())){
                    homeTeamPoint.setText("0");
                    opponentTeamPoint.setText("0");
                }else{
                    homeTeamPoint.setText(tournament.getScore_h());
                    opponentTeamPoint.setText(tournament.getScore_h2());
                }
                break;
            }else{
                if(TextUtils.isEmpty(tournament.getScore_o())){
                    homeTeamPoint.setText("0");
					opponentTeamPoint.setText("0");
				}else{
					homeTeamPoint.setText(tournament.getScore_o2());
					opponentTeamPoint.setText(tournament.getScore_o());
				}
			}
		}
		opponentTeamName.setText(tournament.getOpponent().getName());
        if(!mTournament.isVerify() && TimeUtils.compareCurrentTime(mTournament.getEvent_date())){
            // 赛事未认证且赛事已经结束时，显示提交按钮
            setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
        }
        getScoreInfo();
	}
	
	
	private boolean isHome(){
		for(int i=0;i<myTeam.size();i++){
			if(mTournament.getHome_court().getObjectId()
					.equals(myTeam.get(i).getObjectId())){
				return true;
			}
		}
		return false;
	}
	
	
	/**
	 * 获取本场比赛个人积分
	 */
	private void getPersonalScore(FindListener<PlayerScore> listener){
		if(getUser()!=null){
			BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
			query.addWhereEqualTo("player", getUser());
			query.addWhereEqualTo("competition", mTournament);
			query.include("player,league,competition,team");
			query.setLimit(1);
			query.findObjects(mContext, listener);
		}
	}
	
	/**
	 * 初始化个人积分信息
	 * @param score
	 */
	private void initMyScoreLayout(PlayerScore score){
		if(score==null){
			if(getUser().getNickname()!=null){
				myName.setText(getUser().getNickname());
			}else{
				myName.setText(getUser().getUsername());
			}
		}else{
			if(score.getPlayer().getNickname()!=null){
				myName.setText(score.getPlayer().getNickname());
			}else{
				myName.setText(score.getPlayer().getUsername());
			}
			myShot.setText(score.getGoals() == null ? "0" : score.getGoals()+"");
			myPass.setText(score.getAssists() == null ? "0" : score.getAssists()+"");
			myAvg.setText(score.getAvg()+"");
			myAvgBall = score.getAvg();
            attend.setBackgroundResource(R.drawable.btn_yellow_normal);
            attend.setTextColor(Color.parseColor("#FFFFFF"));
            attend.setTag(true);
		}
	}
	
	/**
	 * 获取本队球员积分列表
	 */
	private void getMyTeamPlayerScore(){
        primaryData = new ArrayList<PlayerScore>();
        data = new ArrayList<PlayerScore>();
		BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
        query.addWhereEqualTo("team", mTournament.getHome_court());
		query.addWhereEqualTo("competition", mTournament);
        query.addWhereNotEqualTo("player", user);
		query.include("player,league,competition,team");
		query.setLimit(20);
		query.findObjects(mContext, new FindListener<PlayerScore>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("请检查网络");
			}

			@Override
			public void onSuccess(List<PlayerScore> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>0){
					primaryData = arg0;
					for(int i=0;i<arg0.size();i++){
						if(!arg0.get(i).getPlayer().getObjectId().equals(user.getObjectId())){
							data.add(arg0.get(i));
							LogUtil.i("remove", "true"+i);
						}
					}
					if(mZdPlayerScoreAdapter == null){
                        mZdPlayerScoreAdapter = new PersonalArgureAdapter(mContext, data, mTournament.getHome_court());
                        zdPlayerScoreList.setAdapter(mZdPlayerScoreAdapter);
					}else{
                        mZdPlayerScoreAdapter.notifyDataSetChanged();
					}
				}else{
					LogUtil.i(TAG,"没有该球队球员在该场比赛的积分信息。");
				}
			}

            @Override
            public void onFinish() {
                super.onFinish();
                swipeLayout.setRefreshing(false);
            }
        });
	}
/*
* 获取客队积分列表
* */
    private void getKdPlayerScore(){
        BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
        query.addWhereEqualTo("team", mTournament.getOpponent());
        query.addWhereEqualTo("competition", mTournament);
        query.addWhereNotEqualTo("player", user);
        query.include("player,league,competition.home_court,competition.opponent,team");
        query.setLimit(20);
        query.findObjects(mContext, new FindListener<PlayerScore>() {

            @Override
            public void onError(int arg0, String arg1) {
                // TODO Auto-generated method stub
                showToast("请检查网络。");
            }

            @Override
            public void onSuccess(List<PlayerScore> arg0) {
                // TODO Auto-generated method stub
                if(arg0!=null&&arg0.size()>0){
                    if(mKdPlayerScoreAdapter == null){
                        mKdPlayerScoreAdapter = new PersonalArgureAdapter(mContext, arg0, mTournament.getOpponent());
                        kdPlayerScoreList.setAdapter(mKdPlayerScoreAdapter);
                    }else{
                        mKdPlayerScoreAdapter.notifyDataSetChanged();
                    }
                }else{
                    LogUtil.i(TAG,"没有该球队球员在该场比赛的积分信息。");
                }
            }

            @Override
            public void onFinish() {
                super.onFinish();
                swipeLayout.setRefreshing(false);
            }
        });
    }
	
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
        zdPlayerScoreList = (ListView)contentView.findViewById(R.id.personal_argue_list);
        kdPlayerScoreList = (ListView) contentView.findViewById(R.id.kd_score_list);
		cpSite = (TextView)contentView.findViewById(R.id.compe_site);
		cpTime = (TextView)contentView.findViewById(R.id.compe_time);
		cpNature = (TextView)contentView.findViewById(R.id.compe_nature);
		
		homeTeamName = (TextView)contentView.findViewById(R.id.vs_name_home);
		homeTeamPoint = (TextView)contentView.findViewById(R.id.vs_point_home);
		
		opponentTeamName = (TextView)contentView.findViewById(R.id.vs_name_opponent);
		opponentTeamPoint = (TextView)contentView.findViewById(R.id.vs_point_opponent);
		
		vsLineupHome = (TextView)contentView.findViewById(R.id.vs_lineup_home);
		vsLineupOpponent = (TextView)contentView.findViewById(R.id.vs_lineup_opponent);
		
		myName = (TextView)contentView.findViewById(R.id.my_name);
		
		shotPrice = (ImageView)contentView.findViewById(R.id.shot_price);
		passPrice = (ImageView)contentView.findViewById(R.id.pass_price);
		
		myShot = (TextView)contentView.findViewById(R.id.my_shot);
		myPass = (TextView)contentView.findViewById(R.id.my_pass);
		myAvg = (TextView)contentView.findViewById(R.id.my_avg);

		myShare = (ImageView)contentView.findViewById(R.id.my_share);
		attend = (Button)contentView.findViewById(R.id.attend);
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
	
	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
        if(mTournament.isVerify()){
            // 已认证的比赛，不能再执行认证操作
            return;
        }
		if(!TeamManager.isCaptain(mTournament.getHome_court(), getUser())
				&&!TeamManager.isCaptain(mTournament.getOpponent(), getUser())){
			showToast("只有队长才能提交认证");
			return;
		}
		int totalAssist = 0;
		for(int i=0;i<primaryData.size();i++){
			totalAssist +=primaryData.get(i).getAssists();
		}
		int totalGoals = 0;
		for(int i=0;i<primaryData.size();i++){
			totalGoals +=primaryData.get(i).getGoals();
		}
		int totalPoint = Integer.parseInt(homeTeamPoint.getText().toString());
        LogUtil.d("bmob", "totalAssist = "+totalAssist);
        LogUtil.d("bmob", "totalGoals = "+totalGoals);
        LogUtil.d("bmob", "totalPoint = "+totalPoint);
		if(totalAssist<=totalPoint && totalGoals<=totalPoint){
            showAffirmDialog();
		}else{
			showToast("数据不正确，无法提交认证");
		}
	}

    Dialog affirmDialog;
    private void showAffirmDialog(){
        if(affirmDialog == null){
            affirmDialog = new AlertDialog.Builder(this)
                    .setTitle("提示")
                    .setMessage("队长提交数据后，其他球员将无法上传比赛数据，不再等一等吗？")
                    .setNegativeButton("再等等",new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.cancel();
                        }
                    })
                    .setPositiveButton("提交",new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            //有可能比分就是0:0，此时需要为Tournment表设置初始值
                            String scoreh=homeTeamPoint.getText().toString();
                            String scoreo=opponentTeamPoint.getText().toString();
                            if(scoreh.equals("0")&&scoreo.equals("0")){
                                updateTournment(mTournament,scoreh,scoreo);
                            }
                            //保存到TeamScore表
                            saveOrUpdateTeamScore();
                            //提交认证
                            authTournament(mTournament);
                        }
                    }).create();
        }
        affirmDialog.show();
    }

    /*
    * 保存或更新球队积分表(TeamScore)
    * */
    private void saveOrUpdateTeamScore(){
//      检测TeamScore表是否存在，不存在就创建，存在就更新数据
        BmobQuery<TeamScore> query =new BmobQuery<TeamScore>();
        query.addWhereEqualTo("competition",mTournament);
        query.addWhereEqualTo("team",MyApplication.getInstance().getCurrentTeam());
        query.setLimit(1);
        query.findObjects(this,new FindListener<TeamScore>() {
            @Override
            public void onSuccess(List<TeamScore> teamScores) {
                int goals,goalagainst,sc;
                Team curTeam = MyApplication.getInstance().getCurrentTeam();
                TeamScore score = new TeamScore();
                if(curTeam.getObjectId().equals(mTournament.getHome_court().getObjectId())){//如果我的球队是主队，则取主队比分
                    goals = Integer.parseInt(homeTeamPoint.getText().toString());
                    goalagainst  = Integer.parseInt(opponentTeamPoint.getText().toString());
                }else{//如果我的球队是主队，则取主队比分
                    goals =Integer.parseInt(opponentTeamPoint.getText().toString());
                    goalagainst  = Integer.parseInt(homeTeamPoint.getText().toString());
                }
                int goalDif =goals-goalagainst;
                if(goalDif>0){
                    sc = 3;
                    score.setWin(true);
                }else if(goalDif==0){
                    score.setDraw(true);
                    sc = 1;
                }else{
                    sc = 0;
                    score.setLoss(true);
                }
                score.setScore(sc);
                score.setGoal_difference(goalDif);
                score.setGoals(goals);
                score.setGoals_against(goalagainst);
                if(teamScores!=null && teamScores.size()>0){
                    score.update(CompetitionInfoActivity.this,teamScores.get(0).getObjectId(),new UpdateListener() {
                        @Override
                        public void onSuccess() {
                            showToast("球队积分更新成功");
                        }

                        @Override
                        public void onFailure(int i, String s) {
                            showToast("球队积分更新失败");
                        }
                    });
                }else{
                    score.setCompetition(mTournament);
                    score.setTeam(curTeam);
                    score.setLeague(mTournament.getLeague());
                    score.setName(curTeam.getName());
                    score.save(CompetitionInfoActivity.this,new SaveListener() {
                        @Override
                        public void onSuccess() {
                            showToast("球队积分保存成功");
                        }

                        @Override
                        public void onFailure(int i, String s) {
                            showToast("球队积分保存失败");
                        }
                    });
                }
            }

            @Override
            public void onError(int i, String s) {
                showToast("球队积分查询失败");
            }
        });
    }

    /*
    * 认证赛事
    * */
	private void authTournament(final Tournament mTournament){
        //调用云端代码查看是否认证成功
		CloudCode.authTournament(mContext, mTournament.getObjectId(), new CloudCodeListener() {
			
			@Override
			public void onSuccess(Object arg0) {
				// TODO Auto-generated method stub
				showToast("发送认证请求成功。");
                //主队队长
                User homeUser = mTournament.getHome_court().getCaptain();
                //组装发给主队队长的推送消息
                PushMessage homeMsg = PushMessageHelper.getAuthMessage(mContext,true,arg0,mTournament);
                //推送给主队队长
                MyApplication.getInstance().getPushHelper2().push2User(homeUser, homeMsg);

                //客队队长
                User visiteUser = mTournament.getOpponent().getCaptain();
                //组装发给客队队长的推送消息
                PushMessage visiteMsg = PushMessageHelper.getAuthMessage(mContext,false,arg0,mTournament);
                //推送给客队队长
                MyApplication.getInstance().getPushHelper2().push2User(visiteUser,visiteMsg);
                //发送比赛报告
                Team team =null;
                if(TeamManager.isCaptain(mTournament.getHome_court(), getUser())){
                    team = mTournament.getHome_court();
                }else{
                    team = mTournament.getOpponent();
                }
                //获取指定球队的所有队员
                TeamManager.getMember(mContext,team,new FindListener<User>() {
                    @Override
                    public void onSuccess(List<User> users) {
                        if(users!=null && users.size()>0){
                            //组装比赛报告并发送给本队所有队员
                            boolean isHome = false;
                            if(TeamManager.isCaptain(mTournament.getHome_court(), getUser())){
                                isHome = true;
                            }else{
                                isHome = false;
                            }
                            int size = users.size();
                            for(int i=0;i<size;i++){
                                PushMessage reportMsg = PushMessageHelper.getReportMsg(isHome,users.get(i),mTournament);
                                MyApplication.getInstance().getPushHelper2().push2User(users.get(i),reportMsg);
                            }
                        }
                    }

                    @Override
                    public void onError(int i, String s) {
                        showToast("比赛报告发送失败");
                    }
                });

                //统计球队数据
				CloudCode.teamData(mContext, team.getObjectId(), new CloudCodeListener() {
					
					@Override
					public void onSuccess(Object arg0) {
						// TODO Auto-generated method stub
						LogUtil.i(TAG,"统计球队数据成功"+arg0);
					}
					
					@Override
					public void onFailure(int arg0, String arg1) {
						// TODO Auto-generated method stub
						LogUtil.i(TAG,"统计球队数据失败"+arg0+arg1);
					}
				});
			}
			
			@Override
			public void onFailure(int statusCode, String arg1) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG,"发送认证请求失败:"+statusCode+"-"+arg1);
				switch (statusCode) {
				case 9010:
					showToast(getString(R.string.no_network));
					break;
                default:
                    showToast("认证信息提交失败");
                    break;
				}
			}
		});
	}


    @Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
        case R.id.iv_i_know:
                findViewById(R.id.rl_ydy1).setVisibility(View.GONE);
                findViewById(R.id.rl_ydy2).setVisibility(View.GONE);
                spfu.setFirstCompetitionInfo(false);
                break;
		case R.id.vs_point_home:
			if(!TeamManager.isCaptain(mTournament.getHome_court(), getUser())
					&&!TeamManager.isCaptain(mTournament.getOpponent(), getUser())){
				return;
			}
            if(!TimeUtils.compareCurrentTime(mTournament.getEvent_date())){
                // 当前时间小于比赛时间，则不能设置比分
                showToast("未到比赛时间，不能编辑");
                return;
            }
			showScoreDialog(mTournament);
			break;
		case R.id.vs_point_opponent:
			if(!TeamManager.isCaptain(mTournament.getHome_court(), getUser())
					&&!TeamManager.isCaptain(mTournament.getOpponent(), getUser())){
				return;
			}
            if(!TimeUtils.compareCurrentTime(mTournament.getEvent_date())){
                // 当前时间小于比赛时间，则不能设置比分
                showToast("未到比赛时间，不能编辑");
                return;
            }
			showScoreDialog(mTournament);
			break;
		case R.id.my_avg:{
			Intent intent = new Intent();
			intent.setClass(mContext, MyGradesActivity.class);
			intent.putExtra("tournament", mTournament);
			intent.putExtra("score", myScore);
			startActivity(intent);
			break;
		}
		case R.id.my_pass:
            if(!TimeUtils.compareCurrentTime(mTournament.getEvent_date())){
                // 当前时间小于比赛时间，则不能设置比分
                showToast("未到比赛时间，不能编辑");
                return;
            }
            if(!mTournament.isVerify()){
                showSelectNumberDialog("pass");
            }else{
                showToast("赛事已通过认证，不能再编辑了");
            }
			break;
		case R.id.my_shot:
            if(!TimeUtils.compareCurrentTime(mTournament.getEvent_date())){
                // 当前时间小于比赛时间，则不能设置比分
                showToast("未到比赛时间，不能编辑");
                return;
            }
            if(!mTournament.isVerify()){
                showSelectNumberDialog("shot");
            }else{
                showToast("赛事已通过认证，不能再编辑了");
            }
			break;
			
		case R.id.my_share://分享
			if(myScore!=null){
				ShareData data = new ShareData();
				data.setTitle("个人比赛数据");
				data.setText("每一次进步，都是辛勤的付出，我在"+myScore.getCompetition().getName()+"比赛中进球"+myScore.getGoals()+
						"次，助攻"+myScore.getAssists()+"次，大家对我的综合评分是"+myScore.getAvg()+"分，谢谢鼓励！"
						+ShareHelper.getGameData(myScore.getPlayer().getObjectId(), myScore.getCompetition().getObjectId()));
				data.setImageUrl(ShareHelper.iconUrl);
				data.setUrl(ShareHelper.getGameData(myScore.getPlayer().getObjectId(), myScore.getCompetition().getObjectId()));
				ShareHelper.share(CompetitionInfoActivity.this, data);
			}else{
				ShareData data = new ShareData();
				data.setTitle("个人比赛数据");
				data.setText("每一次进步，都是辛勤的付出，我在"+mTournament.getName()+"比赛中进球"+0+
						"次，助攻"+0+"次，大家对我的综合评分是"+0+"分，谢谢鼓励！"
						+ShareHelper.getGameData(getUser().getObjectId(), mTournament.getObjectId()));
				data.setImageUrl(ShareHelper.iconUrl);
				data.setUrl(ShareHelper.getGameData(getUser().getObjectId(), mTournament.getObjectId()));
				ShareHelper.share(CompetitionInfoActivity.this, data);
			}
			break;
		case R.id.attend:
            if(!TimeUtils.compareCurrentTime(mTournament.getEvent_date())){
                // 当前时间小于比赛时间，则不能设置比分
                showToast("未到比赛时间，不能编辑");
                return;
            }
            if(!mTournament.isVerify()){
                clickAttendBtn();
            }else{
                showToast("赛事已通过认证，不能再编辑了");
            }
			break;
		case R.id.vs_name_home:{
			Bundle bundle = new Bundle();
			bundle.putSerializable("team", mTournament.getHome_court());
			Intent intent = new Intent();
			intent.setClass(CompetitionInfoActivity.this, OtherTeamInfoActivity.class);
			intent.putExtra("data", bundle);
			startActivity(intent);
			break;
		}
		case R.id.vs_name_opponent:{
			Bundle bundle = new Bundle();
			bundle.putSerializable("team", mTournament.getOpponent());
			Intent intent = new Intent();
			intent.setClass(CompetitionInfoActivity.this, OtherTeamInfoActivity.class);
			intent.putExtra("data", bundle);
			startActivity(intent);
			break;
		}
		case R.id.vs_lineup_home:{
			Intent in = new Intent();
			in.setClass(CompetitionInfoActivity.this, LineupActivity.class);
			in.putExtra("team", mTournament.getHome_court());
			startActivity(in);
			break;
		}
		case R.id.vs_lineup_opponent:{
			Intent in = new Intent();
			in.setClass(CompetitionInfoActivity.this, LineupActivity.class);
			in.putExtra("team", mTournament.getOpponent());
			startActivity(in);
			break;
		}
		default:
			break;
		}
	}


    /**
     * 处理进球或助攻选择
     * @return
     */
    private View getNumberDialogView(final String type) {
        View view = LayoutInflater.from(this).inflate(
                R.layout.dialog_select_number, null);
        final ScrollerNumberPicker numberPicker = (ScrollerNumberPicker)view.findViewById(R.id.date_number);
        ArrayList<String> ds = new ArrayList<String>();
        for (int i=1; i<=30; i++){
            ds.add(i+"");
        }
        numberPicker.setData(ds);
        numberPicker.setDefault(0);
        Button commit = (Button)view.findViewById(R.id.date_commit);
        commit.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                if("shot".equals(type)){
//                    showToast("您选择的进球数是："+numberPicker.getValue());
                    myShot.setText(numberPicker.getSelectedText());
        			updatePlayerScore(Integer.parseInt(numberPicker.getSelectedText()), null);
                }else if("pass".equals(type)){
//                    showToast("您选择的助攻数是："+numberPicker.getValue());
                    myPass.setText(numberPicker.getSelectedText());
                    updatePlayerScore(null, Integer.parseInt(numberPicker.getSelectedText()));
                }
                showAttendBtn();    //更新进球数或助攻数后处理登场按钮的显示
                numberDialog.cancel();
            }
        });
        view.findViewById(R.id.btn_cancel).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                numberDialog.cancel();
            }
        });
        return view;
    }

    /**
     * 更新进球数或助攻数后处理登场按钮的显示
     */
    private void showAttendBtn(){
        if(!"0".equals(myShot.getText().toString())
                || !"0".equals(myPass.getText().toString())){
            // 进球数或助攻数不为0时，登场的按钮显示选中
            attend.setBackgroundResource(R.drawable.btn_yellow_normal);
            attend.setTextColor(Color.parseColor("#FFFFFF"));
            attend.setTag(true);
        }else{
            attend.setBackgroundResource(R.drawable.bg_ball_number);
            attend.setTextColor(Color.parseColor("#989b9f"));
            attend.setTag(false);
        }
    }

    /*
    * 登场按钮
    * */
    private void clickAttendBtn(){
        if((Boolean)attend.getTag()){
            attend.setBackgroundResource(R.drawable.bg_ball_number);
            attend.setTextColor(Color.parseColor("#989b9f"));
            attend.setTag(false);
        }else{
            attend.setBackgroundResource(R.drawable.btn_yellow_normal);
            attend.setTextColor(Color.parseColor("#FFFFFF"));
            attend.setTag(true);
            int shot = Integer.parseInt(myShot.getText().toString());
            int pass = Integer.parseInt(myPass.getText().toString());
            updatePlayerScore(shot, pass);
        }
    }

    /**
     * 显示选择分数对话框
     * @param type 选择进球数还是助攻数（shot进球pass助攻）
     */
    private void showSelectNumberDialog(String type){
        if(numberDialog == null){
            numberDialog = new AlertDialog.Builder(this).create();
        }
        numberDialog.show();
        numberDialog.setCanceledOnTouchOutside(true);
        numberDialog.setContentView(getNumberDialogView(type));
        numberDialog.getWindow().setGravity(Gravity.CENTER);
        numberDialog.getWindow().setLayout(
                getWindowManager().getDefaultDisplay().getWidth()-30,
                android.view.WindowManager.LayoutParams.WRAP_CONTENT);
    }

    Dialog numberDialog = null;

	/**
	 * 更新球员积分表,参数为-1表示不更新
	 */
	private void updatePlayerScore(final Integer goals,final Integer assists){
		getPersonalScore(new FindListener<PlayerScore>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("请检查网络");
			}

			@Override
			public void onSuccess(List<PlayerScore> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>0){
					PlayerScore score = arg0.get(0);
                    if(goals != null){
                        score.setGoals(goals);
                    }else if(assists != null){
                        score.setAssists(assists);
                    }
					score.update(mContext, new UpdateListener() {
						
						@Override
						public void onSuccess() {
							// TODO Auto-generated method stub
							showToast("更新积分成功");
							CloudCode.userGoalAssist(mContext, getUser().getObjectId(), new CloudCodeListener() {
								
								@Override
								public void onSuccess(Object arg0) {
									// TODO Auto-generated method stub
									LogUtil.i(TAG,"统计用户数据成功。"+arg0.toString());
								}
								
								@Override
								public void onFailure(int arg0, String arg1) {
									// TODO Auto-generated method stub
									LogUtil.i(TAG,"统计用户数据成功。"+arg0+arg1);
								}
							});
						}
						
						@Override
						public void onFailure(int arg0, String arg1) {
							// TODO Auto-generated method stub
							showToast("更新积分失败");
						}
					});
				}else{
					PlayerScore score = new PlayerScore();
					score.setPlayer(getUser());
					if(mTournament.getLeague()!=null){
						score.setLeague(mTournament.getLeague());
					}
					score.setCompetition(mTournament);
					score.setTeam(MyApplication.getInstance().getCurrentTeam());
                    if(goals != null){
                        score.setGoals(goals);
                    }else if(assists != null){
                        score.setAssists(assists);
                    }
					score.save(mContext, new SaveListener() {
						
						@Override
						public void onSuccess() {
							// TODO Auto-generated method stub
							showToast("保存积分成功");
							CloudCode.userGoalAssist(mContext, getUser().getObjectId(), new CloudCodeListener() {
								
								@Override
								public void onSuccess(Object arg0) {
									// TODO Auto-generated method stub
									LogUtil.i(TAG,"统计用户数据成功。"+arg0.toString());
								}
								
								@Override
								public void onFailure(int arg0, String arg1) {
									// TODO Auto-generated method stub
									LogUtil.i(TAG,"统计用户数据成功。"+arg0+arg1);
								}
							});
						}
						
						@Override
						public void onFailure(int arg0, String arg1) {
							// TODO Auto-generated method stub
							showToast("保存积分失败");
						}
					});

				}
			}
		});
	}
	
	
	Dialog timeDialog = null;
	private void showEditDialog(PlayerScore score){
		if(timeDialog == null){
			timeDialog = new AlertDialog.Builder(CompetitionInfoActivity.this).create();
		}
		timeDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(CompetitionInfoActivity.this).inflate(
				R.layout.dialog_edit_member_argue, null);
		timeDialog.show();
		timeDialog.setContentView(view);
		timeDialog.getWindow().setGravity(Gravity.CENTER);
		timeDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth()-30,
				android.view.WindowManager.LayoutParams.WRAP_CONTENT);
		//解决键盘无法弹出的问题
		timeDialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
//		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
		TextView editTitle = (TextView)view.findViewById(R.id.edit_title);
		if(score.getPlayer().getNickname()!=null){
			editTitle.setText("编辑球员 "+score.getPlayer().getNickname()+" 的数据");
		}else{
			editTitle.setText("编辑球员 "+score.getPlayer().getUsername()+" 的数据");
		}
		final EditText goalsInput = (EditText)view.findViewById(R.id.goals_input);
		goalsInput.setText(score.getGoals()+"");
		goalsInput.requestFocus();
		goalsInput.requestFocusFromTouch();
//		showSoftInput(goalsInput);
		final EditText assistsInput = (EditText)view.findViewById(R.id.assists_input);
		assistsInput.setText(score.getAssists()+"");
		TextView editCancel = (TextView)view.findViewById(R.id.edit_cancel);
		TextView editOk = (TextView)view.findViewById(R.id.edit_ok);
		editCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
//				hideSoftInput();
				if(timeDialog!=null&&timeDialog.isShowing()){
					timeDialog.dismiss();
				}
			}
		});
		editOk.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
			}
		});
	}
	
	Dialog scoreDialog = null;
	String scoreh = null;
	String scoreo = null;
	private void showScoreDialog(final Tournament tournament){
		if(scoreDialog == null){
			scoreDialog = new AlertDialog.Builder(CompetitionInfoActivity.this).create();
		}
		scoreDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(CompetitionInfoActivity.this).inflate(
				R.layout.dialog_edit_scores, null);
		scoreDialog.show();
		scoreDialog.setContentView(view);
		scoreDialog.getWindow().setGravity(Gravity.CENTER);
		scoreDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth()-30,
				android.view.WindowManager.LayoutParams.WRAP_CONTENT);
		//解决键盘无法弹出的问题
		scoreDialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
//		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
		TextView editTitle = (TextView)view.findViewById(R.id.edit_title);
	    editTitle.setText("编辑球队得分");
		final EditText goalsInput = (EditText)view.findViewById(R.id.goals_input);
		goalsInput.requestFocus();
		goalsInput.requestFocusFromTouch();
		final EditText assistsInput = (EditText)view.findViewById(R.id.assists_input);
		for(int i=0;i<myTeam.size();i++){
			if(tournament.getHome_court().getObjectId().equals(myTeam.get(i).getObjectId())){//如果当前用户属于主队
				if(TextUtils.isEmpty(tournament.getScore_h())){
					goalsInput.setText("0");
					assistsInput.setText("0");
				}else{
					goalsInput.setText(tournament.getScore_h());
					assistsInput.setText(tournament.getScore_h2());
				}
				break;
			}else{
				if(TextUtils.isEmpty(tournament.getScore_o())){
					goalsInput.setText("0");
					assistsInput.setText("0");
				}else{
					goalsInput.setText(tournament.getScore_o());
					assistsInput.setText(tournament.getScore_o2());
				}
			}
		}
		
		
		TextView editCancel = (TextView)view.findViewById(R.id.edit_cancel);
		TextView editOk = (TextView)view.findViewById(R.id.edit_ok);
		editCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if(scoreDialog!=null&&scoreDialog.isShowing()){
					scoreDialog.dismiss();
				}
			}
		});
		editOk.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
                String scoreh=goalsInput.getText().toString();
                String scoreo=assistsInput.getText().toString();
                updateTournment(tournament,scoreh,scoreo);
			}
		});
	}

    /*
    * 更新Tournment表
    * */
    private void updateTournment(Tournament tournament,final String scoreh,final String scoreo){
        if(TextUtils.isEmpty(scoreh)||TextUtils.isEmpty(scoreo)){
            showToast("请输入球队得分。");
            return;
        }
        boolean isHome = false;
        for(int i=0;i<MyApplication.getInstance().getTeams().size();i++){
            if(tournament.getHome_court().getObjectId().equals(MyApplication.getInstance().getTeams().get(i).getObjectId())){
                isHome = true;
            }
        }
        if(isHome){
            tournament.setScore_h(scoreh);
            tournament.setScore_h2(scoreo);
        }else{
            tournament.setScore_o(scoreo);
            tournament.setScore_o2(scoreh);
        }

        tournament.update(mContext, new UpdateListener() {

            @Override
            public void onSuccess() {
                // TODO Auto-generated method stub
                if(scoreDialog!=null&&scoreDialog.isShowing()){
                    scoreDialog.dismiss();
                }
                showToast("保存球队比分成功。");
                homeTeamPoint.setText(scoreh);
                opponentTeamPoint.setText(scoreo);
            }

            @Override
            public void onFailure(int arg0, String arg1) {
                // TODO Auto-generated method stub
                showToast("保存球队比分失败。请检查网络");
            }
        });
    }

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		super.onBackPressed();
//		hideSoftInput();
	}

    @Override
    public void onRefresh() {
        getScoreInfo();
    }
}
