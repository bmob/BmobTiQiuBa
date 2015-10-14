package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewStub;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextSwitcher;
import android.widget.TextView;
import android.widget.ViewSwitcher.ViewFactory;

import com.baidu.android.pushservice.PushManager;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.umeng.analytics.MobclickAgent;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.PersonalRecordAdapter;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.NumberUtils;
import cn.bmob.zuqiu.utils.SharePreferenceUtil;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.view.views.CircleImageView;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;


public class PersonalCenterFragment extends BaseFragment implements ViewFactory,Runnable,OnRefreshListener{

	View settingsMenu;
	ViewStub settingsViewStub;
	TextView modifyImfo;
	TextView shareMyZhanji;
	TextView settings;
	TextView feedback;
	TextView logout;
	MainActivity mainActivity;

    CircleImageView userAvator;
	TextView userName;
	TextView userAge;
	TextView userLocation;
	TextSwitcher userTeam;
	TextView userCity;
	
	TextView validCompetitions;
	TextView totalCompetitions;
	
	TextView validAssist;
	TextView totalAssist;
	
	TextView validScores;
	TextView totalScores;
	
	TextView validPoints;
	
	TextView friendList;
	TextView nearbyCompetition;
	
	RelativeLayout zhanji;
	TextView homeTeam;
	TextView timeCompetition;
	TextView lastInGoals;
	TextView lastAssistGoals;
	TextView vsPoints;
	TextView opponentTeam;
	
	RelativeLayout saicheng;
	TextView nextHomeTeam;
	TextView nextTime;
	TextView nextSite;
	
	RelativeLayout zhanjiMask;
	RelativeLayout saichengMask;

    LinearLayout last;
    LinearLayout next;
	User user ;
	private CompetitionManager comManager;
	
	private Handler handler = new Handler();
	
	private static final int UPDATE_PERSON_INFO = 1;
	
	private SwipeRefreshLayout swipeLayout;
    @Override
    public void onAttach(Activity activity) {
        // TODO Auto-generated method stub
        super.onAttach(activity);
        if(activity!=null&&activity instanceof MainActivity){
        	mainActivity = (MainActivity) activity;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        user = BmobUser.getCurrentUser(getActivity(), User.class);
        comManager = new CompetitionManager(getActivity());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        View v = inflater.inflate(R.layout.fragment_personal_center, container, false);
        return v;
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        // TODO Auto-generated method stub
        super.onHiddenChanged(hidden);
        if(hidden){
            onBackPressed();
        }
    }

    @Override
    public void onPause() {
        // TODO Auto-generated method stub
        super.onPause();
        MobclickAgent.onPageEnd(this.getClass().getSimpleName());
        handler.removeCallbacks(this);
    }

    
    
    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        MobclickAgent.onPageStart(this.getClass().getSimpleName()); //统计页面
        handler.post(this);
        // 刷新数据
        getPersonalData(user);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onViewCreated(view, savedInstanceState);
        setUpTitle(getString(R.string.main_menu_personal_center));
        setUpRightMenu("", R.drawable.selector_settings);
        initProgressDialog(R.string.loading);
        findViewById(view);
        setListeners();
//        initUserInfo(user); // 先显示用户信息
//        getPersonalData(user);  // 再查询用户的最新数据显示
        if(new SharePreferenceUtil(getActivity()).isFirstPersonalCenter()){
            // 第一次打开此界面
            view.findViewById(R.id.rl_ydy).setVisibility(View.VISIBLE);
        }
    }

	private void setListeners() {
		friendList.setOnClickListener(this);
        nearbyCompetition.setOnClickListener(this);
        
        zhanji.setOnClickListener(this);
        saicheng.setOnClickListener(this);
        
        userAvator.setOnClickListener(this);
	}

	private void findViewById(View view) {
        view.findViewById(R.id.iv_i_know).setOnClickListener(this);
		settingsViewStub = (ViewStub)view.findViewById(R.id.settings_menu);
        friendList = (TextView)view.findViewById(R.id.friend_list);
        nearbyCompetition = (TextView)view.findViewById(R.id.near_compe);
	
        userName = (TextView)view.findViewById(R.id.user_name);
        userAvator = (CircleImageView)view.findViewById(R.id.user_avator);
        userAge = (TextView)view.findViewById(R.id.user_age);
        userLocation = (TextView)view.findViewById(R.id.user_location);
        userTeam = (TextSwitcher)view.findViewById(R.id.user_team);
        userCity = (TextView)view.findViewById(R.id.user_city);
        
        validCompetitions = (TextView)view.findViewById(R.id.valid_competiton);
        totalCompetitions = (TextView)view.findViewById(R.id.total_competiton);
        
        validScores = (TextView)view.findViewById(R.id.valid_scores);
        totalScores = (TextView)view.findViewById(R.id.total_scores);
        
        validAssist = (TextView)view.findViewById(R.id.valid_assist);
        totalAssist = (TextView)view.findViewById(R.id.total_assist);
        
        validPoints = (TextView)view.findViewById(R.id.valid_points);
        
        zhanji = (RelativeLayout)view.findViewById(R.id.zhanji);
        homeTeam = (TextView)view.findViewById(R.id.home_team);
        timeCompetition = (TextView)view.findViewById(R.id.time_compe);
        lastAssistGoals = (TextView)view.findViewById(R.id.last_assist_goals);
        lastInGoals = (TextView)view.findViewById(R.id.last_in_goals);
        vsPoints = (TextView)view.findViewById(R.id.vs_points);
        opponentTeam = (TextView)view.findViewById(R.id.opponent_team);
        
        saicheng = (RelativeLayout)view.findViewById(R.id.saicheng);
        nextHomeTeam = (TextView)view.findViewById(R.id.next_home_team);
        nextTime = (TextView)view.findViewById(R.id.next_time_compe);
        nextSite = (TextView)view.findViewById(R.id.next_site);
        
        zhanjiMask = (RelativeLayout)findViewById(R.id.mask_zhanji);
        saichengMask = (RelativeLayout)findViewById(R.id.mask_saicheng);
	
        last = (LinearLayout)findViewById(R.id.last);
        next = (LinearLayout)findViewById(R.id.next);
        
		userTeam.setFactory(PersonalCenterFragment.this);
        Animation in = AnimationUtils.loadAnimation(getActivity(), R.anim.top_in);//android.R.anim.slide_in_left);   
        Animation out = AnimationUtils.loadAnimation(getActivity(), R.anim.bottom_out);//android.R.anim.slide_out_right);   
        userTeam.setInAnimation(in);   
        userTeam.setOutAnimation(out);  
        
        swipeLayout = (SwipeRefreshLayout) this
                .findViewById(R.id.swipe_refresh);
		swipeLayout.setOnRefreshListener(this);
		// 顶部刷新的样式
		swipeLayout.setColorScheme(R.color.red_light,
		                R.color.green_light,
		                R.color.blue_bright,
		                R.color.orange_light);
	}

	/**
	 * 获取最新数据
	 * @param user
	 */
	private void getPersonalData(User user){
		swipeLayout.setRefreshing(true);
		BmobQuery<User> query = new BmobQuery<User>();
		query.getObject(getActivity(), user.getObjectId(), new GetListener<User>() {
			
			@Override
			public void onSuccess(User arg0) {
				// TODO Auto-generated method stub
				initUserInfo(arg0);
			}
			
			@Override
			public void onFailure(int arg0, String arg1) {
				// TODO Auto-generated method stub
                loadingComplete();
				showToast("请检查网络");
			}
		});
		
	}
	
    private void initUserInfo(User user){
    	if(user == null){
    		return;
    	}
        if(user.getAvator() != null && !TextUtils.isEmpty(user.getAvator().getFileUrl(mainActivity))){
            ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mainActivity), userAvator, ImageLoadOptions.getOptions(R.drawable.detail_user_logo_default,-1));
        }else{
            userAvator.setImageResource(R.drawable.detail_user_logo_default);
        }
    	if(!TextUtils.isEmpty(user.getNickname())){
    		userName.setText(user.getNickname());
    	}else{
    		userName.setText(user.getUsername());
    	}
    	userAge.setText("年龄:"+TimeUtils.getAgeByDate(user.getBirthday())+"");
        LogUtil.i("modify", "---------------------------------------------- "+userLocation);
    	userLocation.setText("位置:"+getUserLocation(user.getMidfielder() == null?99:user.getMidfielder()));
    	if(!TextUtils.isEmpty(user.getCityname())){
    		userCity.setText("城市:"+user.getCityname());
    	}else{
    		userCity.setText("城市:未知");
    	}
    	LogUtil.i("modify", "CITY:"+user.getCity()+user.getGames()+"xx"+user.getGamesTotal());
    	
    	validCompetitions.setText(user.getGames() == null?"0": user.getGames().toString());
    	totalCompetitions.setText(user.getGamesTotal() == null ? "0" : user.getGamesTotal().toString());
    	validScores.setText(user.getGoals() == null ? "0" : user.getGoals().toString());
    	totalScores.setText(user.getGoalsTotal() == null ? "0" : user.getGoalsTotal().toString());
    	validAssist.setText(user.getAssists() == null ? "0" : user.getAssists().toString());
    	totalAssist.setText(user.getAssistsTotal() == null ? "0" : user.getAssistsTotal().toString());
    	validPoints.setText(NumberUtils.round(user.getScore(), 2, BigDecimal.ROUND_DOWN)+"");
    	getTeams();
    }
	/*
	* 查询当前用户的赛程信息
	* */
    private void getNextCompetition(){
    	List<Team> myTeam = MyApplication.getInstance().getTeams();
    	if(myTeam.size()<=0){
    		return;
    	}
    	comManager.getNextCompetition(myTeam,
    			new FindListener<Tournament>(){

					@Override
					public void onError(int arg0, String arg1) {
						// TODO Auto-generated method stub
						showToast("请检查网络");
                        loadingComplete();
						next.setVisibility(View.GONE);
						saichengMask.setVisibility(View.VISIBLE);
					}

					@Override
					public void onSuccess(List<Tournament> arg0) {
						// TODO Auto-generated method stub
						if(arg0!=null&&arg0.size()>0){
							next.setVisibility(View.VISIBLE);
							saichengMask.setVisibility(View.GONE);
							initNextCompetitionView(arg0.get(0));
						}else{
							next.setVisibility(View.GONE);
							saichengMask.setVisibility(View.VISIBLE);
						}
                        loadingComplete();
					}
    		
    	},1);
    }
    
    private void initNextCompetitionView(Tournament tournament){
    	nextHomeTeam.setText(tournament.getHome_court().getName()+"-"+tournament.getOpponent().getName());
    	nextSite.setText(tournament.getSite()+"");
    	nextTime.setText(TimeUtils.getSaichengDate(tournament.getStart_time()));
    }
    
    /*
    * 获取最新的战绩信息
    * */
    private void getLastCompetition(){
    	comManager.getUserCompetition(user,new FindListener<PlayerScore>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("请检查网络");
                loadingComplete();
				last.setVisibility(View.GONE);
				zhanjiMask.setVisibility(View.VISIBLE);
			}

			@Override
			public void onSuccess(List<PlayerScore> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>0){
					last.setVisibility(View.VISIBLE);
					zhanjiMask.setVisibility(View.GONE);
                    compareCompetition(arg0);
				}else{
					last.setVisibility(View.GONE);
					zhanjiMask.setVisibility(View.VISIBLE);
				}
                loadingComplete();
			}
		});
    }

    /*
    * 比对每场比赛并获取最新的比赛信息
    * */
    private void compareCompetition(List<PlayerScore> arg0){
        int size = arg0.size();
        List<PlayerScore> scores = new ArrayList<PlayerScore>();
        scores.clear();
        for(int i=0;i<size;i++){
            Tournament tour = arg0.get(i).getCompetition();
            BmobDate date = tour.getStart_time();
            //先和当前时间比较，比当前时间小则代表这个比赛已经结束了，可以计入比分
            if(TimeUtils.compareCurrentTime(date)){
                scores.add(arg0.get(i));
            }
        }
        if(scores!=null&&scores.size()>0){
            //有可能tours有多个，再对其进行按照start_time降序排列
            Collections.sort(scores, new Comparator<PlayerScore>() {
                @Override
                public int compare(PlayerScore lhs, PlayerScore rhs) {
                    return PersonalRecordAdapter.compareCurrentTime(lhs.getCompetition().getEvent_date(), rhs.getCompetition().getEvent_date());
                }
            });
            //默认取最新一个
            initLastCompetitionView(scores.get(0));
        }else{
            Log.i("life","暂无比赛信息");
        }
    }

    /**
     * 上一场战绩
     * @param score
     */
    private void initLastCompetitionView(PlayerScore score){
        Tournament comp = score.getCompetition();
    	timeCompetition.setText(TimeUtils.getZhanjiDate(comp.getStart_time()));
    	homeTeam.setText(comp.getHome_court().getName());
    	opponentTeam.setText(comp.getOpponent().getName());
    	if(comp.isVerify()){//是否认证过，认证过的话，就可以随便取分数啦
    	    vsPoints.setText(comp.getScore_h()+"-"+comp.getScore_h2());
    	}else{
    		for(int i=0;i<teams.size();i++){
                //判断是否为主客队
    			if(teams.get(i).getObjectId().equals(comp.getHome_court().getObjectId())){
    				String score_h = comp.getScore_h()==null?"0":comp.getScore_h();
    				String score_h2 = comp.getScore_h2()==null?"0":comp.getScore_h2();
    				vsPoints.setText(score_h+"-"+score_h2);
    				break;
    			}else{
    				String score_o = comp.getScore_o()==null?"0":comp.getScore_o();
    				String score_o2 =comp.getScore_o2()==null?"0":comp.getScore_o2();
    				vsPoints.setText(score_o2+"-"+score_o);
    			}
    		}
    	}
        //进球和助攻
        lastAssistGoals.setText(score.getAssists() == null ? "0" :score.getAssists()+"");
        lastInGoals.setText(score.getGoals() == null ? "0" : score.getGoals()+"");
    }
    
    private List<Team> teams = new ArrayList<Team>();
	private void getTeams(){
        //查询球队表，用来查询当前用户的所参加的球队
		User user = BmobUser.getCurrentUser(getActivity(), User.class);
		BmobQuery<Team> query = new BmobQuery<Team>();
		BmobQuery<User> users = new BmobQuery<User>();
		users.addWhereEqualTo("objectId", user.getObjectId());
		query.include("captain,lineup");//将队长和球队的阵容都查询出来
		query.addWhereMatchesQuery("footballer", "_User", users);//查询Team表的球员字段中包含当前用户
		query.findObjects(getActivity(), new FindListener<Team>() {
			
			@Override
			public void onSuccess(List<Team> data) {
				// TODO Auto-generated method stub
				LogUtil.i("push","get fav success!"+data.size());
				if(data.size()!=0){
//					userTeam.setText("球队:"+data.get(0).getName());
					MyApplication.getInstance().setTeams(data);
                    teams.clear();
					teams = data;
					if(teams.size()>=2){
						handler.removeCallbacks(PersonalCenterFragment.this);
						handler.post(PersonalCenterFragment.this);
					}else{
						userTeam.setText(data.get(0).getName());
					}
			    	getLastCompetition();
			    	getNextCompetition();
				}else{
                    loadingComplete();
					userTeam.setText("暂无");
                    last.setVisibility(View.GONE);
                    zhanjiMask.setVisibility(View.VISIBLE);
                    next.setVisibility(View.GONE);
                    saichengMask.setVisibility(View.VISIBLE);
				}
			}

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
                loadingComplete();
				LogUtil.i("push","get team failed!"+arg0+arg1);
			}
		});
	}
    
    
    
    /**
     * 根据枚举值返回球员场上位置
     * @param location
     * @return
     */
	private String getUserLocation(int location){
        if(location == 1){
            return "门将";
        }else if(location == 2){
            return "后卫";
        }else if(location == 3){
            return "中场";
        }else if(location == 4){
            return "前锋";
        }else {
            return "";
        }
	}
	
	/**
	 * 根据枚举值返回擅长脚
	 * @param leg
	 * @return
	 */
	private String getGoodat(int leg){
		switch (leg) {
		case 1:
			return "左脚";
		case 2:
			return "右脚";
		case 3:
			return "左右开弓";
		case 4:
			break;
		}
		return "左脚";
	}
	
    @Override
    protected void onRightMenuClick() {
    	// TODO Auto-generated method stub
    	super.onRightMenuClick();
//    	Intent intent = new Intent(getActivity(),ViewGroupExample.class);
//    	startActivity(intent);
    	if(settingsMenu == null){
    		settingsMenu = settingsViewStub.inflate();
    		settingsMenu.setOnTouchListener(new OnTouchListener() {
				
				@Override
				public boolean onTouch(View v, MotionEvent event) {
					// TODO Auto-generated method stub
					settingsMenu.setVisibility(View.GONE);
					return true;
				}
			});
    		modifyImfo = (TextView)settingsMenu.findViewById(R.id.person_settings_modify);
    		shareMyZhanji = (TextView)settingsMenu.findViewById(R.id.person_settings_share);
    		settings = (TextView)settingsMenu.findViewById(R.id.person_settings_setup);
    		feedback = (TextView)settingsMenu.findViewById(R.id.person_settings_fb);
    		logout = (TextView)settingsMenu.findViewById(R.id.person_settings_logout);
    		modifyImfo.setOnClickListener(this);
    		shareMyZhanji.setOnClickListener(this);
    		settings.setOnClickListener(this);
    		feedback.setOnClickListener(this);
    		logout.setOnClickListener(this);
    	}else{
    		if(settingsMenu.getVisibility()!=View.VISIBLE)
    			settingsMenu.setVisibility(View.VISIBLE);
    		else
    			settingsMenu.setVisibility(View.GONE);
    	}
    }
    
    
    @Override
    public void onClick(View v) {
    	// TODO Auto-generated method stub
    	super.onClick(v);
    	switch (v.getId()) {
        case R.id.iv_i_know:
                new SharePreferenceUtil(getActivity()).setFirstPersonalCenter(false);
                findViewById(R.id.rl_ydy).setVisibility(View.GONE);
                break;
    	case R.id.friend_list:
    		Intent frientIntent = new Intent();
    		frientIntent.setClass(getActivity(), FriendListActivity.class);
    		startActivity(frientIntent);
    		break;
    	case R.id.near_compe:
    		Intent compeIntent = new Intent();
    		compeIntent.setClass(getActivity(), NearCompetitionsActivity.class);
    		compeIntent.putExtra("type", Constant.COMPETITION_NEAR);
    		compeIntent.putExtra("user", user);
    		startActivity(compeIntent);
    		break;
		case R.id.person_settings_modify:
			onBackPressed();
			Intent intent = new Intent();
			intent.setClass(getActivity(), ModifyInfomationActivity.class);
			startActivityForResult(intent, UPDATE_PERSON_INFO);
			break;
		case R.id.person_settings_share:
			ShareData data = new ShareData();
			data.setTitle("一起来踢球吧");
			data.setText("每一次进步，都是辛勤的付出！我的总体表现是："+ShareHelper.getPersonalTotalData(user.getObjectId()));
			data.setImageUrl(ShareHelper.iconUrl);
			data.setUrl(ShareHelper.getPersonalTotalData(user.getObjectId()));
			ShareHelper.share(getActivity(), data);
			break;
		case R.id.person_settings_setup:
			mainActivity.showToast("设置");
			onBackPressed();
//			BmobPush.startWork(getActivity(),Constant.BMOB_APP_ID);
//			BmobPushManager manager = new BmobPushManager(getActivity());
//			BmobQuery<BmobInstallation> query = BmobInstallation.getQuery();
//			query.addWhereEqualTo("uid", user.getUsername());
//			manager.setQuery(query);
//			manager.pushMessage("haha");
//			LogUtil.i(TAG,"push end"+user.getInstallId());
			break;
		case R.id.person_settings_fb:
		    mainActivity.showToast("反馈");
		    onBackPressed();
			break;
		case R.id.person_settings_logout:
			onBackPressed();
            User u = BmobUser.getCurrentUser(mainActivity, User.class);
            u.setPushUserId("");
            u.setPushChannelId("");
            u.update(mainActivity, new UpdateListener() {
                @Override
                public void onSuccess() {
                    
                }

                @Override
                public void onFailure(int i, String s) {

                }

                @Override
                public void onFinish() {
                    super.onFinish();
                    BmobUser.logOut(mainActivity);
                }
            });
            // 将pushUserId和PushChannelId清空
            PushManager.stopWork(mainActivity);
            MyApplication.getInstance().clearCache();
			Intent intent1 = new Intent();
			intent1.setClass(getActivity(), LoginActivity.class);
			startActivity(intent1);
			getActivity().finish();
			break;
		case R.id.zhanji://点击战绩
			Intent zhanjiIntent2 = new Intent();
			zhanjiIntent2.setClass(getActivity(), ZhanJiActivity.class);
			zhanjiIntent2.putExtra("type", Constant.RECORD_MY);
			zhanjiIntent2.putExtra("user", user);
			startActivity(zhanjiIntent2);
			break;
		case R.id.saicheng://点击赛程
			Intent compeIntent2 = new Intent();
    		compeIntent2.setClass(getActivity(), NearCompetitionsActivity.class);
    		compeIntent2.putExtra("type", Constant.COMPETITION_MY);
    		compeIntent2.putExtra("user", user);
    		startActivity(compeIntent2);
			break;
		case R.id.user_avator:
			Intent detailInfo  = new Intent();
			detailInfo.setClass(getActivity(), UserInfoActivity.class);
			detailInfo.putExtra("user", user);
			startActivity(detailInfo);
			break;
		default:
			break;
		}
    }
    
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    	// TODO Auto-generated method stub
    	super.onActivityResult(requestCode, resultCode, data);
    	switch (requestCode) {
		case UPDATE_PERSON_INFO:
			if(resultCode == Activity.RESULT_OK){
				//刷新界面
				User user = BmobUser.getCurrentUser(getActivity(), User.class);
				initUserInfo(user);
				LogUtil.i("remove","update"+user.getMidfielder());
			}
			break;

		default:
			break;
		}
    }
    
    public int getSettingsMenuVisibility(){
    	if(settingsMenu == null){
    		return View.GONE;
    	}else{
    		return settingsMenu.getVisibility();
    	}
    }
    
    public void onBackPressed(){
    	if(settingsMenu!=null&&settingsMenu.getVisibility()==View.VISIBLE){
    		settingsMenu.setVisibility(View.GONE);
    	}
    }

    int i= -1;
	@Override
	public void run() {
		// TODO Auto-generated method stub
		i++;
		if(i>1){
			i = 0;
		}
		if(teams.size()>=2 && teams.size()>i){
			userTeam.setText(teams.get(i).getName());
			handler.postDelayed(this, 2000L);
		}else{
			if(teams.size()==1){
				userTeam.setText(teams.get(0).getName());
			}
		}
	}

	@Override
	public View makeView() {
		// TODO Auto-generated method stub
		TextView textView = new TextView(getActivity());   
	     textView.setTextSize(14);   
	     textView.setTextColor(Color.parseColor("#989b9f"));
	     return textView; 
	}

	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
		getPersonalData(user);
	}

    private void loadingComplete(){
        swipeLayout.setRefreshing(false);
        dismissDialog();
    }
}
