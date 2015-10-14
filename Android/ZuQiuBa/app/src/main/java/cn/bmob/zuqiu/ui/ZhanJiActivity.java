package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.PersonalRecordAdapter;
import cn.bmob.zuqiu.adapter.TeamRecordAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;
/*
* 战绩表
* */
public class ZhanJiActivity extends BaseActivity implements OnRefreshListener{

	private List<PlayerScore> data = new ArrayList<PlayerScore>();
	private List<Tournament> teamDatas = new ArrayList<Tournament>();//球队的战绩
	private ListView list;
	private BaseAdapter mAdapter;
	private User mUser;
	private CompetitionManager manager;
	private TextView emptyView;
	private TextView timeYear;
	private SwipeRefreshLayout swipeLayout;
	int recordType = 0;
	private Team team;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_near_competition);
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
        mUser = (User) getIntent().getSerializableExtra("user");
        manager = new CompetitionManager(mContext);
        recordType = getIntent().getIntExtra("type", Constant.RECORD_MY);
        initProgressDialog(R.string.loading);
        //查询战绩
        queryZhanji();
	}

    private void queryZhanji(){
        //初始化
        swipeLayout.setRefreshing(true);
        timeYear.setVisibility(View.VISIBLE);
        timeYear.setText(TimeUtils.getCurrentYear()+"年");
        if(recordType== Constant.RECORD_MY||recordType ==Constant.RECORD_OTHER){//查询的是当前用户/他人的战绩
            setUpAction(mActionBarTitle, "个人战绩表", 0, View.VISIBLE);
            getUserZhanji(mUser);
        }else if(recordType== Constant.RECORD_MYTEAM){//我的球队战绩
            setUpAction(mActionBarTitle, "球队战绩表", 0, View.VISIBLE);
            getMyTeamZhanji();
        }else if(recordType ==Constant.RECORD_OTHERTEAM){//别的球队的战绩
            setUpAction(mActionBarTitle, "球队战绩表", 0, View.VISIBLE);
            team = (Team)getIntent().getSerializableExtra("team");
            getTeamZhanji(team);
        }
    }
	/*
	* 获取我的球队的战绩
	* */
	private void getMyTeamZhanji(){
		TeamManager.getTeams(mContext, mUser, new FindListener<Team>() {
			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				loadingComplete();
			}

			@Override
			public void onSuccess(List<Team> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>0){
					User user = BmobUser.getCurrentUser(mContext, User.class);
					if(user.getObjectId().equals(mUser.getObjectId())){
						getTeamZhanji(MyApplication.getInstance().getCurrentTeam());
					}else{
						getTeamZhanji(arg0.get(0));
					}
				}else{
                    loadingComplete();
					showToast("没有相关比赛");
				}
			}
		});
	}
	
	
	private void getTeamZhanji(Team currentTeam){
		if(currentTeam!=null){
		List<Team> myTeam = new ArrayList<Team>();
		myTeam.add(currentTeam);
    	manager.getLastCompetition(myTeam,new FindListener<Tournament>() {

					@Override
					public void onError(int arg0, String arg1) {
						// TODO Auto-generated method stub
						loadingComplete();
						showToast("请检查网络");
					}

					@Override
					public void onSuccess(List<Tournament> dataList) {
						// TODO Auto-generated method stub
						if(dataList!=null && dataList.size()!=0){
                            LogUtil.i(TAG,"size:"+dataList.size());
                            teamDatas.clear();
                            teamDatas = dataList;
							if(mAdapter==null){
								mAdapter = new TeamRecordAdapter(mContext, dataList);
								list.setAdapter(mAdapter);
							}else{
								((TeamRecordAdapter)mAdapter).setData(dataList);
							}
						}else{
							showToast("您暂时还没有比赛");
						}
						loadingComplete();
					}
				},500);
		}
	}
	
	/*
	* 获取指定用户的战绩
	* */
	private void getUserZhanji(User user){
		manager.getUserCompetition(user,new FindListener<PlayerScore>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				loadingComplete();
				showToast("请检查网络");
			}

			@Override
			public void onSuccess(List<PlayerScore> dataList) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG,"size:"+dataList.size());
				if(dataList!=null && dataList.size()!=0){
					data.clear();
                    data = dataList;
					if(mAdapter==null){
						mAdapter = new PersonalRecordAdapter(mContext, data);
						list.setAdapter(mAdapter);
					}else{
						((PersonalRecordAdapter)mAdapter).setData(data);
					}
				}else{
					showToast("您暂时还没有比赛");
				}
                loadingComplete();
			}
		});
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		timeYear = (TextView)contentView.findViewById(R.id.time_year);
		list = (ListView)contentView.findViewById(R.id.competition_list);
		emptyView = (TextView)contentView.findViewById(R.id.empty_competiton);
//		list.setEmptyView(emptyView);
		swipeLayout = (SwipeRefreshLayout) this
                .findViewById(R.id.swipe_refresh);
		swipeLayout.setOnRefreshListener(this);
		// 顶部刷新的样式
		swipeLayout.setColorScheme(R.color.red_light,
		                R.color.green_light,
		                R.color.blue_bright,
		                R.color.orange_light);
		list.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
//				showToast("click"+position);
				Intent intent = new Intent();
		    	intent.setClass(mContext, CompetitionInfoActivity.class);
                if(recordType== Constant.RECORD_MY||recordType ==Constant.RECORD_OTHER){//查询的是当前用户/他人的战绩
                    intent.putExtra("type","user");
                    intent.putExtra("tournament", data.get(position).getCompetition());
                }else if(recordType== Constant.RECORD_MYTEAM){//我的球队战绩
                    intent.putExtra("type","team");
                    intent.putExtra("tournament", teamDatas.get(position));
                }else if(recordType ==Constant.RECORD_OTHERTEAM){//别的球队的战绩
                    intent.putExtra("type","team");
                    intent.putExtra("tournament", teamDatas.get(position));
                }
		    	startActivity(intent);
			}
		});
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}

	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
		queryZhanji();
	}

    private void loadingComplete(){
        swipeLayout.setRefreshing(false);
        dismissDialog();
    }
	
}
