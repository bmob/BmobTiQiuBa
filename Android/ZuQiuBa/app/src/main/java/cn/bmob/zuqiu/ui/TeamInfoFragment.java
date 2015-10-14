package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewStub;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.listener.DeleteListener;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.TeamArgueAdapter;
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.UserManager;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.Lineup;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;
import cn.bmob.zuqiuj.bean.WrapContentHeightViewPager;

/*
* 球队管理（用户有球队时显示）
* */
public class TeamInfoFragment extends BaseFragment implements SwipeRefreshLayout.OnRefreshListener {

	public static final String TAG = "TeamInfoFragment";
	private WrapContentHeightViewPager viewPager;
	private ImageView circleIndicator;
	private ImageView[] circleIndicators;
	private LinearLayout circleLayout;
	private ArrayList<View> pagerViews = new ArrayList<View>();
	private LayoutInflater inflater;
	
	View settingsMenu;
	ViewStub settingsViewStub;
	TextView teamInfo;
	TextView memBerManage;
	TextView createOrSearchTeam;
	TextView changeTeam;
	TextView exitTeam;
	
	ImageView teamLogo;
	TextView teamMemberNum;
	TextView teamName;
	TextView teamArea;
	TextView teamTime;
	TextView teamCaptain;
	TextView teamAbout;
	TextView teamApply;
	
	RelativeLayout teamInfoLayout;
	TextView teamInfoIn;
	TextView teamInfoContent;
	
	Team firstTeam;
	int teamIndex = 0;
	
	Animation in;
	Animation out;
	
	User user;
	
	RelativeLayout zhanji;
	TextView homeTeam;
	TextView timeCompetition;
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
	
	RelativeLayout zhenrong_content;
	RelativeLayout saishi_content;
	
	TextView saishiName;
	TextView zhenrongName;
	
	private CompetitionManager comManager;
	private Dialog mDialog;
	
	private League currentLeague;
	
	private List<User> lineupList = new ArrayList<User>();
	
//	private RelativeLayout teamList;
//	private ListView myTeamList;
	private LinearLayout teamContent;

    private SwipeRefreshLayout swipeLayout;
	
	private static final int UPDATE_TEAM_INFO = 2;
	@Override
	public void onAttach(Activity activity) {
		// TODO Auto-generated method stub
		super.onAttach(activity);
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		user = BmobUser.getCurrentUser(getActivity(), User.class);
		comManager = new CompetitionManager(getActivity());
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		this.inflater = inflater;
		View v = inflater.inflate(R.layout.fragment_team_manage,container,false);
		return v;
	}
	
	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
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
    		teamInfo = (TextView)settingsMenu.findViewById(R.id.settings_team_info);
    		memBerManage = (TextView)settingsMenu.findViewById(R.id.settings_member_manage);
    		if(TeamManager.isCaptain(firstTeam, user)){
    			teamInfo.setVisibility(View.VISIBLE);
    			memBerManage.setVisibility(View.VISIBLE);
    		}else{
    			teamInfo.setVisibility(View.GONE);
    			memBerManage.setVisibility(View.GONE);
    		}
    		createOrSearchTeam = (TextView)settingsMenu.findViewById(R.id.settings_create_or_search_team);
    		changeTeam = (TextView)settingsMenu.findViewById(R.id.settings_change_team);

            if (MyApplication.getInstance().getTeams().size()>1){
                changeTeam.setVisibility(View.VISIBLE);
            }else{
                changeTeam.setVisibility(View.GONE);
            }
            exitTeam = (TextView)settingsMenu.findViewById(R.id.settings_exit_team);
    		teamInfo.setOnClickListener(this);
    		memBerManage.setOnClickListener(this);
    		createOrSearchTeam.setOnClickListener(this);
    		changeTeam.setOnClickListener(this);
    		exitTeam.setOnClickListener(this);
    	}else{
    		if(settingsMenu.getVisibility()!=View.VISIBLE){
    			settingsMenu.setVisibility(View.VISIBLE);
        		if(TeamManager.isCaptain(firstTeam, user)){
        			teamInfo.setVisibility(View.VISIBLE);
        			memBerManage.setVisibility(View.VISIBLE);
        		}else{
        			teamInfo.setVisibility(View.GONE);
        			memBerManage.setVisibility(View.GONE);
        		}
    		}
    		else
    			settingsMenu.setVisibility(View.GONE);
    	}
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
	public void onViewCreated(View view, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onViewCreated(view, savedInstanceState);
		setUpTitle("球队管理");
		setUpRightMenu("", R.drawable.team_menu);
		firstTeam = MyApplication.getInstance().getTeams().get(0);
		MyApplication.getInstance().setCurrentTeam(firstTeam);
		settingsViewStub = (ViewStub)view.findViewById(R.id.team_menu);
		viewPager = (WrapContentHeightViewPager)findViewById(R.id.viewpager);
		circleLayout = (LinearLayout)findViewById(R.id.viewGroup);
		View teamArgue1 = inflater.inflate(R.layout.team_argue, null);
		TextView validCp = (TextView)teamArgue1.findViewById(R.id.valid_compe);
		TextView totalCp = (TextView)teamArgue1.findViewById(R.id.total_compe);
		TextView validWin = (TextView)teamArgue1.findViewById(R.id.valid_win);
		TextView totalWin = (TextView)teamArgue1.findViewById(R.id.total_win);
		TextView validDraw = (TextView)teamArgue1.findViewById(R.id.valid_draw);
		TextView totalDraw = (TextView)teamArgue1.findViewById(R.id.total_draw);
		TextView validLoss = (TextView)teamArgue1.findViewById(R.id.valid_loss);
		TextView totalLoss = (TextView)teamArgue1.findViewById(R.id.total_loss);
		validCp.setText(firstTeam.getAppearances()+"");
		totalCp.setText(firstTeam.getAppearancesTotal()+"");
		validWin.setText(""+firstTeam.getWin());
		totalWin.setText(""+firstTeam.getWinTotal());
		validDraw.setText(firstTeam.getDraw()+"");
		totalDraw.setText(firstTeam.getDrawTotal()+"");
		validLoss.setText(firstTeam.getLoss()+"");
		totalLoss.setText(firstTeam.getLossTotal()+"");
		View teamArgue2 = inflater.inflate(R.layout.team_argue1, null);
		TextView validDif = (TextView)teamArgue2.findViewById(R.id.valid_difference);
		TextView totalDif = (TextView)teamArgue2.findViewById(R.id.total_difference);
		TextView validDraw1 = (TextView)teamArgue2.findViewById(R.id.valid_draw);
		TextView totalDraw1 = (TextView)teamArgue2.findViewById(R.id.total_draw);
		TextView validLoss1 = (TextView)teamArgue2.findViewById(R.id.valid_loss);
		TextView totalLoss1 = (TextView)teamArgue2.findViewById(R.id.total_loss);
		validDif.setText(firstTeam.getGoal_difference()+"");
		totalDif.setText(firstTeam.getGoalDifferenceTotal()+"");
		validDraw1.setText(firstTeam.getGoals()+"");
		totalDraw1.setText(firstTeam.getGoalsTotal()+"");
		validLoss1.setText(firstTeam.getGoals_against()+"");
		totalLoss1.setText(firstTeam.getGoalsAgainstTotal()+"");
		pagerViews.add(teamArgue1);
		pagerViews.add(teamArgue2);
		circleIndicators = new ImageView[pagerViews.size()];
		for(int i=0;i<pagerViews.size();i++){
			circleIndicator=new ImageView(getActivity());
			LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(  
                    LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			lp.leftMargin = 16;
			lp.rightMargin = 16;
			circleIndicator.setLayoutParams(lp);
			circleIndicators[i]=circleIndicator;
			if (i==0)
			{	
				circleIndicators[i].setBackgroundResource(R.drawable.bg_circle_indicator_chosen);						
			}else {
				circleIndicators[i].setBackgroundResource(R.drawable.bg_circle_indicator_normal);
			}
			circleLayout.addView(circleIndicators[i]);
		}
		viewPager.setAdapter(new TeamArgueAdapter(getActivity(),pagerViews));
		viewPager.setOnPageChangeListener(new MyListener());
		
		
		teamLogo = (ImageView)findViewById(R.id.team_logo);
		teamMemberNum = (TextView)findViewById(R.id.team_menber_number);
		teamName = (TextView)findViewById(R.id.team_name);
		teamArea = (TextView)findViewById(R.id.team_area);
		teamTime = (TextView)findViewById(R.id.team_time);
		teamCaptain = (TextView)findViewById(R.id.team_captain);
		teamAbout = (TextView)findViewById(R.id.team_info);
		teamApply = (TextView)findViewById(R.id.in_team);
		
		teamInfoLayout = (RelativeLayout)findViewById(R.id.team_intro_layout);
		teamInfoIn = (TextView)findViewById(R.id.team_info_in);
		teamInfoContent = (TextView)findViewById(R.id.team_info_content);
		
        zhanji = (RelativeLayout)view.findViewById(R.id.zhanji);
        homeTeam = (TextView)view.findViewById(R.id.home_team);
        timeCompetition = (TextView)view.findViewById(R.id.time_compe);
        vsPoints = (TextView)view.findViewById(R.id.vs_points);
        opponentTeam = (TextView)view.findViewById(R.id.opponent_team);
   
        saicheng = (RelativeLayout)view.findViewById(R.id.saicheng);
        nextHomeTeam = (TextView)view.findViewById(R.id.next_home_team);
        nextTime = (TextView)view.findViewById(R.id.next_time_compe);
        nextSite = (TextView)view.findViewById(R.id.next_site);
 
		teamLogo.setOnClickListener(this);
		teamAbout.setOnClickListener(this);
		teamApply.setOnClickListener(this);
		teamInfoLayout.setOnClickListener(this);
		teamInfoIn.setOnClickListener(this);
		
        zhanjiMask = (RelativeLayout)findViewById(R.id.mask_zhanji);
        saichengMask = (RelativeLayout)findViewById(R.id.mask_saicheng);

        last = (LinearLayout)findViewById(R.id.last);
        next = (LinearLayout)findViewById(R.id.next);
        last.setOnClickListener(this);
        next.setOnClickListener(this);
        
        zhenrong_content = (RelativeLayout)findViewById(R.id.zhenrong_content);
        saishi_content = (RelativeLayout)findViewById(R.id.saishi_content);
        saishiName = (TextView)findViewById(R.id.saishi_name);
        zhenrongName = (TextView)findViewById(R.id.zhenrong_names);
        
        zhenrong_content.setOnClickListener(this);
        saishi_content.setOnClickListener(this);

        teamContent = (LinearLayout)findViewById(R.id.team_content);

        swipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_refresh);
        swipeLayout.setOnRefreshListener(this);
        // 顶部刷新的样式
        swipeLayout.setColorScheme(R.color.red_light,
                R.color.green_light,
                R.color.blue_bright,
                R.color.orange_light);
        if(MyApplication.getInstance().getTeams().size() >=1 ){
            teamIndex = 0;
            firstTeam = MyApplication.getInstance().getTeams().get(teamIndex);
        }else{
            showToast("没有球队的显示");
        }
		initTeamInfo(firstTeam);
		getLastCompetition();
		getNextCompetition();
		getLineup();
		getLeague();
	}

    private void refTeamInfo(){
        BmobQuery<Team> query = new BmobQuery<Team>();
        query.getObject(getActivity(), firstTeam.getObjectId(), new GetListener<Team>() {
            @Override
            public void onSuccess(Team team) {
                initTeamInfo(firstTeam);
            }

            @Override
            public void onFailure(int i, String s) {

            }

            @Override
            public void onFinish() {
                super.onFinish();
                loadingComplete();
            }
        });
    }

    @Override
    public void onPause() {
        // TODO Auto-generated method stub
        super.onPause();
        MobclickAgent.onPageEnd(this.getClass().getSimpleName());
    }

    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        MobclickAgent.onPageStart(this.getClass().getSimpleName()); //统计页面
    }

    private void initTeamInfo(Team team){
        if(team.getAvator() != null && !TextUtils.isEmpty(team.getAvator().getFileUrl(getActivity()))){
            ImageLoader.getInstance().displayImage(team.getAvator().getFileUrl(getActivity()), teamLogo, ImageLoadOptions.getOptions(R.drawable.team_logo_default,-1));
        }else{
            teamLogo.setImageResource(R.drawable.team_logo_default);
        }
		
		teamName.setText(team.getName());
		teamArea.setText("区域:"+team.getCityname());
        if(team.getFound_time()!=null){
            teamTime.setText("成立时间:"+TimeUtils.getCurrentYear(team.getFound_time()));
        }else{
            teamTime.setText("成立时间:未知");
        }
		if(team.getCaptain()!=null){
			if(team.getCaptain().getNickname()!=null){
				teamCaptain.setText("队长:"+team.getCaptain().getNickname());
			}else{
				teamCaptain.setText("队长:"+team.getCaptain().getUsername());
			}
		}
		teamInfoContent.setText(team.getAbout());
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo("footballer", new BmobPointer(team));
		query.findObjects(getActivity(), new FindListener<User>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
			}

			@Override
			public void onSuccess(List<User> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>=0){
					teamMemberNum.setText("成员  "+arg0.size()+"人");
				}
			}
		});
	}
	
	private void getLastCompetition(){
    	List<Team> myTeam = new ArrayList<Team>();
    	myTeam.add(firstTeam);
    	if(myTeam.size()<=0){
    		return;
    	}
        showDialog();
    	comManager.getLastCompetition(myTeam, new FindListener<Tournament>() {

					@Override
					public void onError(int arg0, String arg1) {
						// TODO Auto-generated method stub
						showToast("请检查网络");
						last.setVisibility(View.GONE);
						zhanjiMask.setVisibility(View.VISIBLE);
                        loadingComplete();
					}

					@Override
					public void onSuccess(List<Tournament> arg0) {
						// TODO Auto-generated method stub
						if(arg0!=null&&arg0.size()>0){
							last.setVisibility(View.VISIBLE);
							zhanjiMask.setVisibility(View.GONE);
							initLastCompetitionView(arg0.get(0));
						}else{
							last.setVisibility(View.GONE);
							zhanjiMask.setVisibility(View.VISIBLE);
						}
                        loadingComplete();
					}
				});
    }
	
	 /**
     * 上一场战绩
     * @param compe
     */
    private void initLastCompetitionView(Tournament compe){
    	List<Team> teams = MyApplication.getInstance().getTeams();
    	timeCompetition.setText(TimeUtils.getZhanjiDate(compe.getStart_time()));
    	homeTeam.setText(compe.getHome_court().getName());
    	opponentTeam.setText(compe.getOpponent().getName());
    	if(compe.isVerify()){
            String score_h = compe.getScore_h()==null?"0":compe.getScore_h();
            String score_h2 = compe.getScore_h2()==null?"0":compe.getScore_h2();
    		vsPoints.setText(score_h+"-"+score_h2);
    	}else{
    		for(int i=0;i<teams.size();i++){
    			if(teams.get(i).getObjectId().equals(compe.getHome_court().getObjectId())){
    				String score_h = compe.getScore_h()==null?"0":compe.getScore_h();
    				String score_h2 = compe.getScore_h2()==null?"0":compe.getScore_h2();
    				vsPoints.setText(score_h+"-"+score_h2);
    				break;
    			}else{
    				String score_o = compe.getScore_o()==null?"0":compe.getScore_o();
    				String score_o2 = compe.getScore_o2()==null?"0":compe.getScore_o2();
    				vsPoints.setText(score_o2+"-"+score_o);
    			}
    		}
    	}
    }
	
    
    private void getNextCompetition(){
    	List<Team> myTeam = new ArrayList<Team>();
    	myTeam.add(firstTeam);
    	if(myTeam.size()<=0){
    		return;
    	}
        showDialog();
    	comManager.getNextCompetition(myTeam,
    			new FindListener<Tournament>(){

					@Override
					public void onError(int arg0, String arg1) {
						// TODO Auto-generated method stub
						showToast("请检查网络");
						next.setVisibility(View.GONE);
						saichengMask.setVisibility(View.VISIBLE);
                        loadingComplete();
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
    
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.team_logo:
			Intent intentMember = new Intent();
			intentMember.setClass(getActivity(), TeamMemberActivity.class);
			intentMember.putExtra("team", firstTeam);
			startActivity(intentMember);
			break;
		case R.id.team_info_in:
			out = AnimationUtils.loadAnimation(getActivity(), R.anim.right_out);
			teamInfoLayout.startAnimation(out);
			teamInfoLayout.setVisibility(View.GONE);
			teamInfoLayout.setFocusable(false);
			teamInfoLayout.setClickable(false);
			break;
		case R.id.team_intro_layout:
			if(teamInfoLayout.getVisibility()==View.VISIBLE){
				out = AnimationUtils.loadAnimation(getActivity(), R.anim.right_out);
				teamInfoLayout.startAnimation(out);
				teamInfoLayout.setVisibility(View.GONE);
				teamInfoLayout.setFocusable(false);
				teamInfoLayout.setClickable(false);
			}
			break;
		case R.id.team_info:
			teamInfoLayout.setVisibility(View.VISIBLE);
			in = AnimationUtils.loadAnimation(getActivity(), R.anim.left_in);
			teamInfoLayout.startAnimation(in);
			break;
		case R.id.in_team:
            //申请入队
            PushMessage msg = PushMessageHelper.getApplyTeamMessage(getActivity(),firstTeam);
            MyApplication.getInstance().getPushHelper2().push2User(firstTeam.getCaptain(),msg);
			break;
		case R.id.settings_team_info:
			Intent intent = new Intent();
			intent.setClass(getActivity(), TeamDetailActivity.class);
			intent.putExtra("team", firstTeam);
			startActivityForResult(intent,UPDATE_TEAM_INFO);
			onBackPressed();
			break;
		case R.id.settings_member_manage:{
			Intent intent2 = new Intent();
			intent2.setClass(getActivity(), TeamMemberActivity.class);
			intent2.putExtra("team", firstTeam);
			startActivity(intent2);
			onBackPressed();
			break;
		}
		case R.id.settings_create_or_search_team:
			Intent intent3 = new Intent();
			intent3.setClass(getActivity(), CreteOrSearchTeamActivity.class);
//			intent3.putExtra("team", firstTeam);
			startActivity(intent3);
			onBackPressed();
			break;
		case R.id.settings_change_team:
            switchTeam();
			break;
		case R.id.settings_exit_team:
            showExitTeamDialog();
			onBackPressed();
			break;
		case R.id.yes:
            // 退出球队
            hideTeamDialog();
            if(((TextView)v).getText().equals("确定")){//普通球员退出球队
                TeamManager.deleteMember(getActivity(), firstTeam, user, new UpdateListener() {

                    @Override
                    public void onSuccess() {
                        // TODO Auto-generated method stub
                        UserManager ma = new UserManager(getActivity());
                        ma.exitTeam(user, firstTeam, new UpdateListener() {

                            @Override
                            public void onSuccess() {
                                // TODO Auto-generated method stub
                                showToast("退出球队成功");
                                // 退订该球队的消息
                                MyApplication.getInstance().getPushHelper2().deleteTag(firstTeam.getObjectId());
                                //发送给队长
                                PushMessage msg1 = PushMessageHelper.getQuitTeamMessage(getActivity(),firstTeam);
                                MyApplication.getInstance().getPushHelper2().push2User(firstTeam.getCaptain(),msg1);
                              //从内存中清除
//                              MyApplication.getInstance().setCurrentTeam(null);
                                Intent intent = new Intent(Constant.ACTION_TEAM_QUIT_UPDATE);
                                getActivity().sendBroadcast(new Intent());
                            }

                            @Override
                            public void onFailure(int arg0, String arg1) {
                                // TODO Auto-generated method stub
                                LogUtil.i(TAG, "quit team failed:"+arg0+arg1);
                            }
                        });
                    }

                    @Override
                    public void onFailure(int arg0, String arg1) {
                        // TODO Auto-generated method stub
                        showToast("退出失败，请检查网络");
                    }
                });
            }else{//队长解散球队
                TeamManager.deleteTeam(getActivity(),firstTeam,new DeleteListener() {
                    @Override
                    public void onSuccess() {
                        showToast("球队解散成功");
                        Intent intent = new Intent(Constant.ACTION_TEAM_QUIT_UPDATE);
                        getActivity().sendBroadcast(new Intent());
                    }

                    @Override
                    public void onFailure(int i, String s) {
                        LogUtil.i(TAG, "quit team failed:"+i+"-"+s);
                    }
                });
            }

        break;
        case R.id.tv_updateCaptain:
            // 更换队长
            Intent i = new Intent();
            i.setClass(getActivity(), TeamDetailActivity.class);
            i.putExtra("team", firstTeam);
            startActivityForResult(i,UPDATE_TEAM_INFO);
            onBackPressed();
            hideTeamDialog();
            break;
		case R.id.no:
			hideTeamDialog();
			break;
		case R.id.saishi_content:
			if(currentLeague!=null){
				Intent intent4 = new Intent();
				intent4.setClass(getActivity(), LeagueDetailActivity.class);
				intent4.putExtra("league", currentLeague);
				startActivity(intent4);
			}
			break;
		case R.id.zhenrong_content:
            // 阵容
			Intent in = new Intent();
			in.setClass(getActivity(), LineupActivity.class);
			in.putExtra("team", firstTeam);
			startActivityForResult(in, 1);
			break;
		case R.id.last://球队管理界面的战绩
			Intent zhanjiIntent2 = new Intent();
			zhanjiIntent2.setClass(getActivity(), ZhanJiActivity.class);
			zhanjiIntent2.putExtra("type", Constant.RECORD_MYTEAM);
			zhanjiIntent2.putExtra("user", user);
			startActivity(zhanjiIntent2);
			break;
		case R.id.next:
			Intent compeIntent = new Intent();
    		compeIntent.setClass(getActivity(), NearCompetitionsActivity.class);
    		compeIntent.putExtra("type", Constant.COMPETITION_CURRENT_TEAM);
    		compeIntent.putExtra("user", user);
    		startActivity(compeIntent);
			break;
		default:
			break;
		}
	}
    
    private void switchTeam(){
        if(MyApplication.getInstance().getTeams().size()==0){
//            showToast("显示无球队界面");
            MainActivity ma = (MainActivity) getActivity();
            View view = new View(getActivity());
            view.setId(R.id.main_menu_team);
            ma.onClick(view);
            return;
        }
        if(teamIndex==0 && MyApplication.getInstance().getTeams().size()==2){
            teamIndex++;
        }else if(teamIndex==1 && MyApplication.getInstance().getTeams().size()==2){
            teamIndex--;
        }else if(MyApplication.getInstance().getTeams().size()==1){
            teamIndex = 0;
//            showToast("您目前只加入了一支球队，无法切换");
//            return;
        }
        firstTeam = MyApplication.getInstance().getTeams().get(teamIndex);
        MyApplication.getInstance().setCurrentTeam(firstTeam);
        initArgue(pagerViews.get(0), firstTeam);
        initArgue1(pagerViews.get(1), firstTeam);
        initTeamInfo(firstTeam);
        getLastCompetition();
        getNextCompetition();
        getLineup();
        getLeague();
        onBackPressed();
        showToast("切换成功");
    }
	
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		if(resultCode==Activity.RESULT_OK){
			switch (requestCode) {
			case 1:
				getLineup();
				break;
			case UPDATE_TEAM_INFO:
				TeamManager.getMyTeams(getActivity(), new FindListener<Team>() {

					@Override
					public void onError(int arg0, String arg1) {
						// TODO Auto-generated method stub
					}

					@Override
					public void onSuccess(List<Team> arg0) {
						// TODO Auto-generated method stub
                        MyApplication.getInstance().setTeams(arg0);
                        if(arg0!=null&&arg0.size()>0){
							firstTeam = MyApplication.getInstance().getTeams().get(teamIndex);
							MyApplication.getInstance().setCurrentTeam(firstTeam);
							initArgue(pagerViews.get(0), firstTeam);
							initArgue1(pagerViews.get(1), firstTeam);
							initTeamInfo(firstTeam);
							getLastCompetition();
							getNextCompetition();
							getLineup();
							getLeague();
							LogUtil.i("remove", "up team");
						}
					}
				});

				break;
			default:
				break;
			}
		}
	}

    /**
     * 获取阵容
     */
	private void getLineup(){
        showDialog();
		lineupList.clear();
		BmobQuery<Lineup> query = new BmobQuery<Lineup>();
		query.addWhereEqualTo("team", firstTeam);
		query.include("team,goalkeeper");
		query.order("-updatedAt");
		query.findObjects(getActivity(), new FindListener<Lineup>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				loadingComplete();
			}

			@Override
			public void onSuccess(List<Lineup> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>0){
					User user = arg0.get(0).getGoalkeeper();
					if(user!=null){
						lineupList.add(user);
					}
					
					getMemberByType(arg0.get(0),"back");
					getMemberByType(arg0.get(0), "striker");
					getMemberByType(arg0.get(0), "forward");
				}
                loadingComplete();
			}
		});
	}
	
	/**
	 * 获取后卫人员
	 */
	private void getMemberByType(Lineup lineup,final String memberType){
		LogUtil.i(TAG,"ID:"+lineup.getObjectId()+lineupList.size());
		if(lineup==null)
			return;
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo(memberType, new BmobPointer(lineup));
		query.findObjects(getActivity(), new FindListener<User>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onSuccess(List<User> arg0) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG, "SIZE:"+memberType+arg0.size());
				if(arg0!=null&&arg0.size()>0){
					lineupList.addAll(arg0);
				}
				User mUser = null;
				StringBuilder sb =new StringBuilder();
				String name = null;
				for(int i=0;i<lineupList.size();i++){
					mUser = lineupList.get(i);
					if(mUser.getNickname()!=null){
						name = mUser.getNickname();
					}else{
						name = mUser.getUsername();
						
					}
					sb.append(name).append(",");
				}
				zhenrongName.setText(sb.toString());
			}
		});
	}
	
	
	
	/**
	 * 获取我正在参加的比赛
	 */
	private void getLeague(){
		if(MyApplication.getInstance().getCurrentTeam()==null){
			return;
		}
        showDialog();
		BmobQuery<League> query = new BmobQuery<League>();
		BmobQuery<Team> innerQuery = new BmobQuery<Team>();
		innerQuery.addWhereEqualTo("objectId", MyApplication.getInstance().getCurrentTeam().getObjectId());
		query.addWhereMatchesQuery("teams", "Team", innerQuery);
		query.order("-createdAt");
		query.findObjects(getActivity(), new FindListener<League>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				LogUtil.i("league", "not FINDED:"+arg0+arg1);
                loadingComplete();
			}

			@Override
			public void onSuccess(List<League> arg0) {
				// TODO Auto-generated method stub
				LogUtil.i("league", "FINDED:"+arg0.size());
				if(arg0 != null && arg0.size() > 0){
					currentLeague = arg0.get(0);
					saishiName.setText(currentLeague.getName());
				}
                loadingComplete();
			}
		});

	}
	
	private void showExitTeamDialog(){
        if(mDialog == null){
            mDialog = new AlertDialog.Builder(getActivity()).create();
        }
        mDialog.setCanceledOnTouchOutside(true); //点击其他区域dialog消失

        View view = LayoutInflater.from(getActivity()).inflate(
                R.layout.dialog_exit_team, null);
        TextView msg = (TextView) view.findViewById(R.id.title);
        TextView yes = (TextView)view.findViewById(R.id.yes);
        TextView no = (TextView)view.findViewById(R.id.no);
        TextView tv_updateCaptain = (TextView) view.findViewById(R.id.tv_updateCaptain);
        if(TeamManager.isCaptain(firstTeam, user)){
            msg.setText("你当前为球队"+firstTeam.getName()+"的队长，退出球队请先到[ 球队资料 ]中更换队长或直接解散球队。");
            yes.setText("解散球队");
        }else{
            msg.setText("您当前球队为"+firstTeam.getName()+",确定要退出当前球队吗？");
            tv_updateCaptain.setVisibility(View.GONE);
        }

        mDialog.show();
        mDialog.setContentView(view);
        mDialog.getWindow().setGravity(Gravity.CENTER);
        mDialog.getWindow().setLayout(
                getActivity().getWindowManager().getDefaultDisplay().getWidth()-60,
                android.view.WindowManager.LayoutParams.WRAP_CONTENT);

        yes.setOnClickListener(this);
        no.setOnClickListener(this);
        tv_updateCaptain.setOnClickListener(this);
	}
	
	private void hideTeamDialog(){
		if(mDialog!=null&&mDialog.isShowing()){
			mDialog.dismiss();
		}
	}
	
	private void initArgue(View teamArgue1,Team firstTeam){
		TextView validCp = (TextView)teamArgue1.findViewById(R.id.valid_compe);
		TextView totalCp = (TextView)teamArgue1.findViewById(R.id.total_compe);
		TextView validWin = (TextView)teamArgue1.findViewById(R.id.valid_win);
		TextView totalWin = (TextView)teamArgue1.findViewById(R.id.total_win);
		TextView validDraw = (TextView)teamArgue1.findViewById(R.id.valid_draw);
		TextView totalDraw = (TextView)teamArgue1.findViewById(R.id.total_draw);
		TextView validLoss = (TextView)teamArgue1.findViewById(R.id.valid_loss);
		TextView totalLoss = (TextView)teamArgue1.findViewById(R.id.total_loss);
		validCp.setText(firstTeam.getAppearances()+"");
		totalCp.setText(firstTeam.getAppearancesTotal()+"");
		validWin.setText(""+firstTeam.getWin());
		totalWin.setText(""+firstTeam.getWinTotal());
		validDraw.setText(firstTeam.getDraw()+"");
		totalDraw.setText(firstTeam.getDrawTotal()+"");
		validLoss.setText(firstTeam.getLoss()+"");
		totalLoss.setText(firstTeam.getLossTotal()+"");
	}
	
	private void initArgue1(View teamArgue2,Team firstTeam){
		TextView validDif = (TextView)teamArgue2.findViewById(R.id.valid_difference);
		TextView totalDif = (TextView)teamArgue2.findViewById(R.id.total_difference);
		TextView validDraw1 = (TextView)teamArgue2.findViewById(R.id.valid_draw);
		TextView totalDraw1 = (TextView)teamArgue2.findViewById(R.id.total_draw);
		TextView validLoss1 = (TextView)teamArgue2.findViewById(R.id.valid_loss);
		TextView totalLoss1 = (TextView)teamArgue2.findViewById(R.id.total_loss);
		validDif.setText(firstTeam.getGoal_difference()+"");
		totalDif.setText(firstTeam.getGoalDifferenceTotal()+"");
		validDraw1.setText(firstTeam.getGoals()+"");
		totalDraw1.setText(firstTeam.getGoalsTotal()+"");
		validLoss1.setText(firstTeam.getGoals_against()+"");
		totalLoss1.setText(firstTeam.getGoalsAgainstTotal()+"");
	}

    @Override
    public void onRefresh() {
        refTeamInfo();
    }

    class MyListener implements OnPageChangeListener{

		@Override
		public void onPageScrollStateChanged(
				int arg0)
		{
			// TODO Auto-generated method stub
			
		}

		@Override
		public void onPageScrolled(int arg0,
				float arg1, int arg2)
		{
			// TODO Auto-generated method stub
			
		}

		@Override
		public void onPageSelected(int arg0){
			for(int i=0;i<circleIndicators.length;i++) {				
				circleIndicators[arg0].setBackgroundResource(R.drawable.bg_circle_indicator_chosen);
				if (arg0!=i)
				{					
					circleIndicators[i].setBackgroundResource(R.drawable.bg_circle_indicator_normal);
				}
			}
			
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

    private void showDialog(){
        if(!swipeLayout.isRefreshing()){
            initProgressDialog(R.string.loading);
        }
    }

    private void loadingComplete(){
        swipeLayout.setRefreshing(false);
        dismissDialog();
    }
	
}
