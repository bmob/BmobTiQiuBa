package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.RelativeLayout;
import android.widget.TextSwitcher;
import android.widget.TextView;
import android.widget.ViewSwitcher.ViewFactory;

import com.nostra13.universalimageloader.core.ImageLoader;

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
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.UserHelper;
import cn.bmob.zuqiu.utils.UserManager;
import cn.bmob.zuqiu.view.views.CircleImageView;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class PersonalInfoFragment extends BaseFragment implements ViewFactory,Runnable {
	MainActivity mainActivity;

    CircleImageView userAvator;
	TextView userName;
	TextView userAge;
	TextView userLocation;
	TextSwitcher userTeam;
	TextView userCity;

	TextView validCompetitions;
	TextView totalCompetitions;;

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

	private List<User> friends = new ArrayList<User>();
	private boolean isFriend = false;

	RelativeLayout zhanjiMask;
	RelativeLayout saichengMask;

	RelativeLayout last;
	RelativeLayout next;

	User personal;
	private CompetitionManager comManager;
	private TeamManager teamManager;
	private List<Team> teams = new ArrayList<Team>();

	private Handler handler = new Handler();

    String type = null;
	@Override
	public void onAttach(Activity activity) {
		// TODO Auto-generated method stub
		super.onAttach(activity);
		if (activity != null && activity instanceof MainActivity) {
			mainActivity = (MainActivity) activity;
		}
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
        personal = (User) getArguments().getSerializable("user");
        type = getArguments().getString("type");//如果来自消息页面。，则需要发送添加好友反馈的消息
		friends = MyApplication.getInstance().getFriends();
		comManager = new CompetitionManager(getActivity());
		teamManager = new TeamManager();
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		View v = inflater.inflate(R.layout.fragment_personal_info, container,
				false);
		return v;
	}

	@Override
	public void onHiddenChanged(boolean hidden) {
		// TODO Auto-generated method stub
		super.onHiddenChanged(hidden);
	}

	@Override
	public void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		handler.removeCallbacks(this);
	}

	@Override
	public void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		handler.post(this);
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onViewCreated(view, savedInstanceState);
		view.findViewById(R.id.fragment_actionbar).setVisibility(View.GONE);
		findViewById(view);
		setListeners();
		if (friends.size() >= 0) {
			for (int i = 0; i < friends.size(); i++) {
				if (friends.get(i).getObjectId().equals(personal.getObjectId())) {
					isFriend = true;
					break;
				}
			}
		}
		if (isFriend) {
			friendList.setText("删除好友");
		} else {
			friendList.setText("加为好友");
		}
		nearbyCompetition.setText("邀请入队");
        if(type!=null && type.equals("msg")){//如果来自消息页面，则需要重新查询用户信息
            getUserInfo();
        }else{
            initUserInfo(personal);
        }
	}

    /*获取指定用户的信息*/
    private void getUserInfo(){
        initProgressDialog("正在查询中...");
        BmobQuery<User> query = new BmobQuery<User>();
        query.getObject(getActivity(),personal.getObjectId(),new GetListener<User>() {
            @Override
            public void onSuccess(User user) {
                dismissDialog();
                if(user!=null){
                    personal = user;
                    initUserInfo(user);
                }
            }

            @Override
            public void onFailure(int i, String s) {
                dismissDialog();
                showToast("查询用户信息失败,请重试...");
            }
        });
    }

	private void initUserInfo(User user) {
		if (user == null) {
			return;
		}
        if(user.getAvator() != null && !TextUtils.isEmpty(user.getAvator().getFileUrl(getActivity()))){
            ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(getActivity()), userAvator, ImageLoadOptions.getOptions(R.drawable.detail_user_logo_default,-1));
        }else{
            userAvator.setImageResource(R.drawable.detail_user_logo_default);
        }
		if (!TextUtils.isEmpty(user.getNickname())) {
			userName.setText(user.getNickname());
		} else {
			userName.setText(user.getUsername());
		}
		userAge.setText("年龄:" + TimeUtils.getAgeByDate(user.getBirthday()) + "");
		userLocation.setText("位置:"
				+ UserHelper.getUserLocation(user.getMidfielder()));
		if (!TextUtils.isEmpty(user.getCityname())) {
			userCity.setText("城市:" + user.getCityname());
		} else {
			userCity.setText("城市:未知");
		}
		LogUtil.i("modify", "CITY:" + user.getCity());
		totalCompetitions.setText(user.getGames() == null ? "0" : user.getGames() + "");
		totalScores.setText(user.getGoals() == null ? "0" :  user.getGoals() + "");
		validPoints.setText(user.getScore() + "");
		getTeams(user);
	}

	private void getTeams(User user) {
		BmobQuery<Team> query = new BmobQuery<Team>();
		BmobQuery<User> users = new BmobQuery<User>();
		users.addWhereEqualTo("objectId", user.getObjectId());
		query.include("captain,lineup");
		query.addWhereMatchesQuery("footballer", "_User", users);
		query.findObjects(getActivity(), new FindListener<Team>() {

			@Override
			public void onSuccess(List<Team> data) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG, "get fav success!" + data.size());
				if (data.size() != 0) {
					// userTeam.setText("球队:"+data.get(0).getName());
					teams.addAll(data);
					if (teams.size() >= 2) {
						handler.post(PersonalInfoFragment.this);
					} else {
						userTeam.setText(data.get(0).getName());
					}
					getLastCompetition(teams);
					getNextCompetition(teams);
				} else {
					userTeam.setText("暂无");
					getLastCompetition(teams);
					getNextCompetition(teams);
				}
			}

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
			}
		});
	}

	private void getLastCompetition(List<Team> myTeam) {
		if (myTeam.size() <= 0) {
			last.setVisibility(View.GONE);
			zhanjiMask.setVisibility(View.VISIBLE);
			return;
		}
        //查询指定用户的战绩
        comManager.getUserCompetition(personal,new FindListener<PlayerScore>() {

            @Override
            public void onError(int arg0, String arg1) {
                // TODO Auto-generated method stub
                showToast("请检查网络");
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
            }
        });
	}

    /*
    *  比对每场比赛并获取最新的比赛信息
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
            Log.i("life", "暂无比赛信息");
        }
    }

	/**
	 * 显示界面
	 * @param score
	 */
	private void initLastCompetitionView(PlayerScore score) {
        Tournament compe = score.getCompetition();
		timeCompetition.setText(TimeUtils.getZhanjiDate(compe.getEvent_date()));
		homeTeam.setText(compe.getHome_court().getName());
		opponentTeam.setText(compe.getOpponent().getName());
        String hs = TextUtils.isEmpty(compe.getScore_h()) ? "0" : compe.getScore_h();
        String os = TextUtils.isEmpty(compe.getScore_o()) ? "0" : compe.getScore_o();
        vsPoints.setText(hs+" - "+os);
        //显示进球和助攻数
        lastAssistGoals.setText(score.getAssists() == null ? "0" : score.getAssists()+ "");
        lastInGoals.setText(score.getGoals() == null ? "0" : score.getGoals()+ "");
	}

	private void getNextCompetition(List<Team> myTeam) {
		if (myTeam.size() <= 0) {
			next.setVisibility(View.GONE);
			saichengMask.setVisibility(View.VISIBLE);
			return;
		}
		comManager.getNextCompetition(myTeam, new FindListener<Tournament>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("请检查网络");
				next.setVisibility(View.GONE);
				saichengMask.setVisibility(View.VISIBLE);
			}

			@Override
			public void onSuccess(List<Tournament> arg0) {
				// TODO Auto-generated method stub
				if (arg0 != null && arg0.size() > 0) {
					next.setVisibility(View.VISIBLE);
					saichengMask.setVisibility(View.GONE);
					initNextCompetitionView(arg0.get(0));
				} else {
					next.setVisibility(View.GONE);
					saichengMask.setVisibility(View.VISIBLE);
				}
			}

		}, 1);
	}

	private void initNextCompetitionView(Tournament tournament) {
		nextHomeTeam.setText(tournament.getHome_court().getName() + "-"
				+ tournament.getOpponent().getName());
		nextSite.setText(tournament.getSite() + "");
		nextTime.setText(TimeUtils.getSaichengDate(tournament.getStart_time()));
	}

	private void setListeners() {
		friendList.setOnClickListener(this);
		nearbyCompetition.setOnClickListener(this);

		zhanji.setOnClickListener(this);
		saicheng.setOnClickListener(this);

		userAvator.setOnClickListener(this);
	}

	private void findViewById(View view) {
		friendList = (TextView) view.findViewById(R.id.friend_list);
		nearbyCompetition = (TextView) view.findViewById(R.id.near_compe);

		userName = (TextView) view.findViewById(R.id.user_name);
		userAvator = (CircleImageView) view.findViewById(R.id.user_avator);
		userAge = (TextView) view.findViewById(R.id.user_age);
		userLocation = (TextView) view.findViewById(R.id.user_location);
		userTeam = (TextSwitcher) view.findViewById(R.id.user_team);
		userCity = (TextView) view.findViewById(R.id.user_city);

		validCompetitions = (TextView) view.findViewById(R.id.valid_competiton);
		totalCompetitions = (TextView) view.findViewById(R.id.total_competiton);

		validScores = (TextView) view.findViewById(R.id.valid_scores);
		totalScores = (TextView) view.findViewById(R.id.total_scores);

		validAssist = (TextView) view.findViewById(R.id.valid_assist);
		totalAssist = (TextView) view.findViewById(R.id.total_assist);

		validPoints = (TextView) view.findViewById(R.id.valid_points);

		zhanji = (RelativeLayout) view.findViewById(R.id.zhanji);
		homeTeam = (TextView) view.findViewById(R.id.home_team);
		timeCompetition = (TextView) view.findViewById(R.id.time_compe);
		lastAssistGoals = (TextView) view.findViewById(R.id.last_assist_goals);
		lastInGoals = (TextView) view.findViewById(R.id.last_in_goals);
		vsPoints = (TextView) view.findViewById(R.id.vs_points);
		opponentTeam = (TextView) view.findViewById(R.id.opponent_team);

		saicheng = (RelativeLayout) view.findViewById(R.id.saicheng);
		nextHomeTeam = (TextView) view.findViewById(R.id.next_home_team);
		nextTime = (TextView) view.findViewById(R.id.next_time_compe);
		nextSite = (TextView) view.findViewById(R.id.next_site);

		zhanjiMask = (RelativeLayout) findViewById(R.id.mask_zhanji);
		saichengMask = (RelativeLayout) findViewById(R.id.mask_saicheng);

		last = (RelativeLayout) findViewById(R.id.last);
		next = (RelativeLayout) findViewById(R.id.next);

		userTeam.setFactory(PersonalInfoFragment.this);
		Animation in = AnimationUtils.loadAnimation(getActivity(),
				R.anim.top_in);// android.R.anim.slide_in_left);
		Animation out = AnimationUtils.loadAnimation(getActivity(),
				R.anim.bottom_out);// android.R.anim.slide_out_right);
		userTeam.setInAnimation(in);
		userTeam.setOutAnimation(out);
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.friend_list:
			if (isFriend) {// 删除
                deleteFriend();
			} else {
			    // 添加好友，发送请求
                addFriend();
			}
			break;
		case R.id.near_compe:// 邀请入队
            if("已邀请".equals(nearbyCompetition.getText().toString())){
                return;
            }
            inviteIntoTheTeam();
			break;
		case R.id.user_avator:
			Intent intent = new Intent();
			intent.setClass(getActivity(), UserInfoActivity.class);
			intent.putExtra("user", personal);
			startActivity(intent);
			break;
		case R.id.zhanji:
			Intent zhanjiIntent2 = new Intent();
			zhanjiIntent2.setClass(getActivity(), ZhanJiActivity.class);
			zhanjiIntent2.putExtra("type", Constant.RECORD_OTHER);
			zhanjiIntent2.putExtra("user", personal);
			startActivity(zhanjiIntent2);
			break;
		case R.id.saicheng:
			Intent compeIntent2 = new Intent();
			compeIntent2
					.setClass(getActivity(), NearCompetitionsActivity.class);
			compeIntent2.putExtra("type", Constant.COMPETITION_MY);
			compeIntent2.putExtra("user", personal);
			startActivity(compeIntent2);
			break;

		default:
			break;
		}
	}

	int i = -1;

	@Override
	public void run() {
		// TODO Auto-generated method stub
		i++;
		if (i > 1) {
			i = 0;
		}
		if (teams.size() >= 2 && teams.size() > i) {
			userTeam.setText(teams.get(i).getName());
			handler.postDelayed(this, 2000L);
		} else {
			if (teams.size() == 1) {
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

    /**
     * 邀请加入球队，一个球队时直接邀请加入这个球队，两个球队时提示用户选择哪知球队
     */
    private void inviteIntoTheTeam(){
        if(MyApplication.getInstance().getTeams() != null && MyApplication.getInstance().getTeams().size()==2){
            String[] items = new String[2];
            for (int i=0; i<2; i++){
                items[i] = MyApplication.getInstance().getTeams().get(i).getName();
            }
            new AlertDialog.Builder(getActivity()).setTitle("选择球队")
                    .setSingleChoiceItems(items, 0, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            inviteIntoTheTeam2(MyApplication.getInstance().getTeams().get(which));
                            dialog.cancel();
                        }
                    })
                    .setNegativeButton("取消", null)
                    .create().show();
        }else if(MyApplication.getInstance().getCurrentTeam() != null){
            inviteIntoTheTeam2(MyApplication.getInstance().getCurrentTeam());
        }
        
    }

    /**
     * 最终的邀请入队操作
     * @param team
     */
    private void inviteIntoTheTeam2(Team team){
        User user = BmobUser.getCurrentUser(getActivity(), User.class);
        if(user.getObjectId().equals(team.getCaptain().getObjectId())){//队长邀请
            PushMessage msg = PushMessageHelper.inviteByCaptainMessage(getActivity(),team);
            MyApplication.getInstance().getPushHelper2().push2User(personal,msg);
        }else{//队员邀请的消息是先发送给队长，由队长同意后再发送给被邀请人
            PushMessage msg = PushMessageHelper.inviteByMemberMessage(team,user,personal);
            MyApplication.getInstance().getPushHelper2().push2User(team.getCaptain(),msg);
        }
        nearbyCompetition.setText("已邀请");
    }
    
    private void addFriend(){//当前用户添加对方为好友
        UserManager manager = new UserManager(getActivity());
        manager.addFriend(personal.getObjectId(), true,new UpdateListener() {

                    @Override
                    public void onSuccess() {
                        // TODO Auto-generated method stub
                        showToast("添加好友成功");
                        boolean isFeed = false;
                        if(type!=null && type.equals("msg")){
                            isFeed = true;
                        }
                        PushMessage msg = PushMessageHelper.getAddFriendMessage(getActivity(),isFeed);
                        //发送给指定用户
                        MyApplication.getInstance().getPushHelper2().push2User(personal,msg);
                        //
                        MyApplication.getInstance().getFriends().remove(personal);
                        friends = MyApplication.getInstance().getFriends();
                        isFriend = true;
                        friendList.setText("删除好友");
                    }

                    @Override
                    public void onFailure(int arg0, String arg1) {
                        // TODO Auto-generated method stub

                    }
                });
    }
    
    private void deleteFriend(){
        UserManager manager = new UserManager(getActivity());
        manager.addFriend(personal.getObjectId(), false,
                new UpdateListener() {

                    @Override
                    public void onSuccess() {
                        // TODO Auto-generated method stub
                        showToast("删除好友成功");
                        MyApplication.getInstance().getFriends()
                                .remove(personal);
                        friends = MyApplication.getInstance()
                                .getFriends();
                        isFriend = false;
                        friendList.setText("添加好友");
                    }

                    @Override
                    public void onFailure(int arg0, String arg1) {
                        // TODO Auto-generated method stub

                    }
                });
    }

}
