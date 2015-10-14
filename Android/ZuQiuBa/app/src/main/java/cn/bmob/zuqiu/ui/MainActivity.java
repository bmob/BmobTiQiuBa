package cn.bmob.zuqiu.ui;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewStub;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.update.BmobUpdateAgent;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseMainActivity;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.SharePreferenceUtil;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class MainActivity extends BaseMainActivity implements OnClickListener {

	private ImageView mainMenu;
	private TextView personalCenter;
	private TextView footerTeam;
	private TextView competition;
	private TextView message;

	private ViewStub menuStub;
	private View menuView;
	private TextView nextCompetion;
	private TextView createCompetition;
	private TextView createLeague;

	private TextView[] mTabs;
	private Fragment[] fragments;
	private int index;
	private int currentTabIndex;

	private PersonalCenterFragment personalFragment;    // 个人中心
	private FootballTeamFragment teamFragment;          // 添加球队（用户没球队时显示）
	private CompetitionFragment competitonFragment;     // 赛事
	private MessageFragment messageFragment;            // 消息
	private TeamInfoFragment teaminfoFragment;          // 球队（用户有球队时显示）

//	private BmobPushManager pushManager;

//	private List<Team> teams = new ArrayList<Team>();

	@Override
	protected void onCreate(Bundle arg0) {
		// TODO Auto-generated method stub
		super.onCreate(arg0);
		setContentView(R.layout.activity_main);
		mainMenu = (ImageView)findViewById(R.id.main_menu);
		menuStub = (ViewStub)findViewById(R.id.main_function);
		personalCenter = (TextView)findViewById(R.id.main_menu_personal_center);
		footerTeam = (TextView)findViewById(R.id.main_menu_team);
		competition = (TextView)findViewById(R.id.main_menu_competition);
		message = (TextView)findViewById(R.id.main_menu_message);
		
		mainMenu.setOnClickListener(this);
		personalCenter.setOnClickListener(this);
		footerTeam.setOnClickListener(this);
		competition.setOnClickListener(this);
		message.setOnClickListener(this);
		
		mTabs = new TextView[]{personalCenter,footerTeam,competition,message,footerTeam};
		personalCenter.setSelected(true);
		
		personalFragment = new PersonalCenterFragment();
		teamFragment = new FootballTeamFragment();
		competitonFragment  = new CompetitionFragment();
		messageFragment = new MessageFragment();
		teaminfoFragment = new TeamInfoFragment();
		
		fragments = new Fragment[]{personalFragment,teamFragment,competitonFragment,messageFragment,teaminfoFragment};
		// 添加显示第一个fragment
        getSupportFragmentManager().beginTransaction().add(R.id.fragment_container, personalFragment).
            add(R.id.fragment_container, teamFragment).hide(teamFragment).show(personalFragment).commit();
        getTeams();
        getFriends();
        isShowMessageFragment(getIntent());
        checkUpdate();
        registerBroadCast();
	}

    NewBroadcastReceiver  newReceiver;

    private void registerBroadCast(){
        // 注册接收消息广播
        newReceiver = new NewBroadcastReceiver();
        IntentFilter intentFilter = new IntentFilter(Constant.ACTION_TEAM_QUIT_UPDATE);
        registerReceiver(newReceiver, intentFilter);
    }

    /**
     * 新消息广播接收者
     *
     */
    private class NewBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.i("life","===========接收到广播==========");
            //显示球队页面
            showTeamFragment();
            // 记得把广播给终结掉
            abortBroadcast();
        }
    }

//    long lastUpdateTime;
    /**
     * 检查版本更新，每天一次
     */
    private void checkUpdate() {
        /* Get Last Update Time from Preferences */
//        lastUpdateTime = new SharePreferenceUtil(this).getLastUpdateTime();
        // 每天检测一次是否有更新
		/* Should Activity Check for Updates Now? */
//        if ((lastUpdateTime + (24 * 60 * 60 * 1000)) < System.currentTimeMillis()) {
			/* Save current timestamp for next Check */
//            lastUpdateTime = System.currentTimeMillis();
//            new SharePreferenceUtil(this).setLastUpdateTime(lastUpdateTime);
			/* Start Update */
            BmobUpdateAgent.update(this);
//        }
    }

    /**
     * 如果是点击的通知栏消息打开的此界面，则显示到消息tab页
     * @param intent
     */
    private void isShowMessageFragment(Intent intent){
        // 如果是点击的消息
        if (intent.getBooleanExtra("ShowMessageFragment", false)){
            onClick(message);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        isShowMessageFragment(intent);
    }

    @Override
	protected void onResume(){
		super.onResume();
        Log.i("life","MainActivity-onresume");
	}

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(newReceiver);
    }


	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.main_menu:
			if (menuView == null) {
				menuView = menuStub.inflate();
				mainMenu.setSelected(true);
				menuView.setOnTouchListener(new OnTouchListener() {

					@Override
					public boolean onTouch(View v, MotionEvent event) {
						// TODO Auto-generated method stub
						return true;
					}
				});
				nextCompetion = (TextView) menuView
						.findViewById(R.id.next_competition);
				createCompetition = (TextView) menuView
						.findViewById(R.id.create_competition);
				createLeague = (TextView) menuView
						.findViewById(R.id.create_league);
				nextCompetion.setOnClickListener(this);
				createCompetition.setOnClickListener(this);
				createLeague.setOnClickListener(this);
			} else {
				if (menuView.getVisibility() == View.VISIBLE) {
					menuView.setVisibility(View.GONE);
					mainMenu.setSelected(false);
				} else if (menuView.getVisibility() == View.GONE) {
					menuView.setVisibility(View.VISIBLE);
					mainMenu.setSelected(true);
				}
			}

			break;
		case R.id.main_menu_personal_center:
			index = 0;
			hideMainMenu();
			break;
		case R.id.main_menu_team:
            LogUtil.d("bmob","显示球队Tab页：size:"+MyApplication.getInstance().getTeams().size());
            if(MyApplication.getInstance().getTeams().size()>0){//如果当前用户有球队的话，则显示球队管理页面
                index = 4;
            }else{
                index = 1;
            }
			hideMainMenu();
			break;
		case R.id.main_menu_competition:
			index = 2;
			hideMainMenu();
			break;
		case R.id.main_menu_message:
			index = 3;
			hideMainMenu();
            //这个1 和notiManager创建时候传入的1 是唯一的
            ((NotificationManager) getSystemService(NOTIFICATION_SERVICE)).cancel(1);
			break;
		case R.id.next_competition:
			getNextCompetition();
            hideMainMenu();
            // 退订111111
//            MyApplication.getInstance().getPushHelper2().deleteTag("959633b195");
			break;
		case R.id.create_competition:
            // 创建比赛
			redictTo(mContext, CreateCompetitionActivity.class, null);
            hideMainMenu();
//            MyApplication.getInstance().getPushHelper2().pushToChannel("959633b195", "111111的球员们请注意了，今年过年不回家。");
			break;
		case R.id.create_league:
            // 创建联赛
			redictTo(mContext, CreateLeagueActivity.class, null);
            hideMainMenu();
            // 订阅111111
//            MyApplication.getInstance().getPushHelper2().setTag("959633b195");
			break;
		default:
			break;
		}

		if (currentTabIndex != index) {
			FragmentTransaction trx = getSupportFragmentManager()
					.beginTransaction();
			trx.hide(fragments[currentTabIndex]);
			if (!fragments[index].isAdded()) {
				trx.add(R.id.fragment_container, fragments[index]);
			}
			trx.show(fragments[index]).commit();
		}
        
        if(index == 4){//TeamInfoFragment(有球队的时候)
            mTabs[currentTabIndex].setSelected(false);
            // 把当前tab设为选中状态
            mTabs[1].setSelected(true);
            currentTabIndex = index;
        }else{
            mTabs[currentTabIndex].setSelected(false);
            // 把当前tab设为选中状态
            mTabs[index].setSelected(true);
            currentTabIndex = index;
        }
	}

    private void showTeamFragment(){
        if(currentTabIndex==4||currentTabIndex==1){//当前页是否为球队页
            if(MyApplication.getInstance().getTeams().size()>0){//如果当前用户有球队的话，则显示球队管理页面
                index = 4;
            }else{
                index = 1;
            }
            if (currentTabIndex != index) {
                FragmentTransaction trx = getSupportFragmentManager()
                        .beginTransaction();
                trx.hide(fragments[currentTabIndex]);
                if (!fragments[index].isAdded()) {
                    trx.add(R.id.fragment_container, fragments[index]);
                }
                trx.show(fragments[index]).commit();
            }
            if(index == 4){//TeamInfoFragment(有球队的时候)
                mTabs[currentTabIndex].setSelected(false);
                // 把当前tab设为选中状态
                mTabs[1].setSelected(true);
                currentTabIndex = index;
            }else{
                mTabs[currentTabIndex].setSelected(false);
                // 把当前tab设为选中状态
                mTabs[index].setSelected(true);
                currentTabIndex = index;
            }
        }

    }

	/**
	 * 下一场比赛
	 */
	private void getNextCompetition() {
		List<Team> myTeam = MyApplication.getInstance().getTeams();
		if (myTeam.size() <= 0) {
			return;
		}
		initProgressDialog(R.string.loading);
		CompetitionManager comManager = new CompetitionManager(this);
		comManager.getNextCompetition(myTeam, new FindListener<Tournament>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("请检查网络。");
				dismissDialog();
			}

			@Override
			public void onSuccess(List<Tournament> arg0) {
				// TODO Auto-generated method stub
				dismissDialog();
				if (arg0 != null && arg0.size() > 0) {
					Intent intent = new Intent();
					intent.setClass(mContext, CompetitionInfoActivity.class);
					intent.putExtra("tournament", arg0.get(0));
					startActivity(intent);
				} else {
					showToast("没有下一场比赛,请先创建比赛");
				}
			}

		}, 1);
	}

    /*
    * 查询用户所属的球队*/
	private void getTeams() {
		User user = BmobUser.getCurrentUser(mContext, User.class);
        Log.i("life","user = "+user.getObjectId());
        BmobQuery<Team> query = new BmobQuery<Team>();
		BmobQuery<User> users = new BmobQuery<User>();
		users.addWhereEqualTo("objectId", user.getObjectId());
		query.include("captain,lineup");
		query.addWhereMatchesQuery("footballer", "_User", users);
		query.findObjects(mContext, new FindListener<Team>() {

			@Override
			public void onSuccess(List<Team> data) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG, "get fav success!" + data.size());
                MyApplication.getInstance().setTeams(data);
                if (data!=null && data.size() != 0) {
					MyApplication.getInstance().setCurrentTeam(MyApplication.getInstance().getTeams().get(0));
					for (int i = 0; i < data.size(); i++) {
						TeamManager.getMember(mContext, data.get(i),new FindListener<User>() {

									@Override
									public void onError(int arg0, String arg1) {
										// TODO Auto-generated method stub
									}

									@Override
									public void onSuccess(List<User> arg0) {
										// TODO Auto-generated method stub
										if (arg0 != null && arg0.size() > 0) {
											MyApplication.getInstance().getTeamMember().addAll(arg0);
										}
									}
								});
					}
				}
			}

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG, "get fav failed!" + arg0 + arg1);
			}
		});
	}

	private void getFriends() {
		User user = BmobUser.getCurrentUser(mContext, User.class);
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo("friends", new BmobPointer(user));
		query.findObjects(mContext, new FindListener<User>() {

			@Override
			public void onError(int errorcode, String errorString) {
				// TODO Auto-generated method stub
			}

			@Override
			public void onSuccess(List<User> list) {
				// TODO Auto-generated method stub
				if (list != null && list.size() > 0) {
					MyApplication.getInstance().setFriends(list);
				}
			}
		});
	}

	private void hideMainMenu() {
		if (menuView != null && menuView.getVisibility() == View.VISIBLE) {
			menuView.setVisibility(View.GONE);
			mainMenu.setSelected(false);
		}
	}

	private static long firstTime;

	/**
	 * 连续按两次返回键就退出
	 */
	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		if (personalFragment != null
				&& personalFragment.getSettingsMenuVisibility() == View.VISIBLE) {
			personalFragment.onBackPressed();
			return;
		}
		if (teaminfoFragment != null
				&& teaminfoFragment.getSettingsMenuVisibility() == View.VISIBLE) {
			teaminfoFragment.onBackPressed();
			return;
		}
		if (firstTime + 2000 > System.currentTimeMillis()) {
            new SharePreferenceUtil(this).setFirstPersonalCenter(false);
			super.onBackPressed();
		} else {
			showToast("再按一次退出程序");
		}
		firstTime = System.currentTimeMillis();
	}
}
