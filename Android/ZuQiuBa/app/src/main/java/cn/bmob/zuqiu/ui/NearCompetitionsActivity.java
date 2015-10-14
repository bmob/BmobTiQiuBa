package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.TournamentListAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class NearCompetitionsActivity extends BaseActivity implements OnRefreshListener{

//	private List<Tournament> data = new ArrayList<Tournament>();
	
	private ListView list;
	private TournamentListAdapter mAdapter;
	private User mUser;
	private CompetitionManager manager;
	private TextView emptyView;
	private TextView timeYear;
	private SwipeRefreshLayout swipeLayout;
	int compeType = 0;
	private Team team;

    String tips = "暂时没有附近的比赛";

	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_near_competition);
		setUpAction(mActionBarTitle, "附近的比赛", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		mUser = (User) getIntent().getSerializableExtra("user");
		team = (Team)getIntent().getSerializableExtra("team");
		manager = new CompetitionManager(mContext);
		compeType = getIntent().getIntExtra("type", Constant.COMPETITION_NEAR);
		if(mUser!=null){
			updateSaicheng();
		}else{
			updateSaicheng2();
		}
	}
	
	
	private void updateSaicheng2() {
		swipeLayout.setRefreshing(true);
		switch (compeType) {
		case Constant.COMPETITION_NEAR:
			setUpAction(mActionBarTitle, "附近的比赛", 0, View.VISIBLE);
			timeYear.setVisibility(View.GONE);
			timeYear.setText(TimeUtils.getCurrentYear()+"年");
			getNearCompetiton();
			break;
		case Constant.COMPETITION_MY:
			setUpAction(mActionBarTitle, "赛程表", 0, View.VISIBLE);
			timeYear.setVisibility(View.GONE);
			timeYear.setText(TimeUtils.getCurrentYear()+"年");
			ArrayList<Team> teams = new ArrayList<Team>();
			teams.add(team);
			getMySaiCheng(teams);
			break;
		case Constant.COMPETITION_CURRENT_TEAM:
			setUpAction(mActionBarTitle, "赛程表", 0, View.VISIBLE);
			timeYear.setVisibility(View.GONE);
			timeYear.setText(TimeUtils.getCurrentYear()+"年");
			getCurrentTeamSaiCheng(team);
			break;
		default:
			break;
		}
	}

	private void updateSaicheng() {
		swipeLayout.setRefreshing(true);
		switch (compeType) {
		case Constant.COMPETITION_NEAR:
			setUpAction(mActionBarTitle, "附近的比赛", 0, View.VISIBLE);
			timeYear.setVisibility(View.GONE);
			timeYear.setText(TimeUtils.getCurrentYear()+"年");
			getNearCompetiton();
			break;
		case Constant.COMPETITION_MY:
			setUpAction(mActionBarTitle, "赛程表", 0, View.VISIBLE);
			timeYear.setVisibility(View.GONE);
			timeYear.setText(TimeUtils.getCurrentYear()+"年");
			getSaiChengofMine();
			break;
		case Constant.COMPETITION_CURRENT_TEAM:
			setUpAction(mActionBarTitle, "赛程表", 0, View.VISIBLE);
			timeYear.setVisibility(View.GONE);
			timeYear.setText(TimeUtils.getCurrentYear()+"年");
			getSaiChengofTeam();
			break;
		default:
			break;
		}
	}

	private void getNearCompetiton() {
		if(mUser.getCity()==null){
			LogUtil.i("compe", "city null");
			return;
		}
//		initProgressDialog(R.string.loading);
		LogUtil.i("compe", "city not null show"+mUser.getCity());
		manager.getNearCompetition(mUser.getCity(), new FindListener<Tournament>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
//				dismissDialog();
				LogUtil.i("compe", "city not null error");
			}

			@Override
			public void onSuccess(List<Tournament> dataList) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
				LogUtil.i("compe", "city not null success");
//				dismissDialog();
				LogUtil.i(TAG,"size:"+dataList.size());
				if(dataList.size()!=0){
					if(mAdapter==null){
						mAdapter = new TournamentListAdapter(mContext, dataList,false);
						list.setAdapter(mAdapter);
					}else{
						mAdapter.setData(dataList);
					}
				}else{
					showToast(tips);
				}
			}
		});
	}
	
	private void getSaiChengofMine(){
		TeamManager.getTeams(mContext, mUser, new FindListener<Team>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
			}

			@Override
			public void onSuccess(List<Team> arg0) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
				if(arg0!=null&&arg0.size()>0){
					getMySaiCheng(arg0);
				}else{
					showToast("没有您的比赛。");
				}
			}
		});
	}
	
	private void getMySaiCheng(List<Team> teams){
		if(teams.size()<=0){
			showToast("您没有安排比赛。");
			return;
		}
//		initProgressDialog(R.string.loading);
		manager.getNextCompetition(teams,
				new FindListener<Tournament>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
//				dismissDialog();
			}

			@Override
			public void onSuccess(List<Tournament> dataList) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
//				dismissDialog();
				LogUtil.i(TAG,"size:"+dataList.size());
				if(dataList.size()!=0){
//					data = dataList;
					if(mAdapter==null){
						mAdapter = new TournamentListAdapter(mContext, dataList,false);
						list.setAdapter(mAdapter);
					}else{
						mAdapter.setData(dataList);
					}
				}else{
					showToast("您暂时还没有比赛。");
				}
			}
		}, 500);
	}
	
	
	private void getSaiChengofTeam(){
		TeamManager.getTeams(mContext, mUser, new FindListener<Team>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
			}

			@Override
			public void onSuccess(List<Team> arg0) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
				if(arg0!=null&&arg0.size()>0){
					User user = BmobUser.getCurrentUser(mContext, User.class);
					if(user.getObjectId().equals(mUser.getObjectId())){
						getCurrentTeamSaiCheng(MyApplication.getInstance().getCurrentTeam());
					}else{
						getCurrentTeamSaiCheng(arg0.get(0));
					}
				}else{
					showToast("没有您的比赛。");
				}
			}
		});
	}
	
	private void getCurrentTeamSaiCheng(Team currentTeam){
		if(currentTeam!=null){
			List<Team> teams = new ArrayList<Team>();
			teams.add(currentTeam);
//			initProgressDialog(R.string.loading);
			manager.getNextCompetition(teams,
					new FindListener<Tournament>() {

				@Override
				public void onError(int arg0, String arg1) {
					// TODO Auto-generated method stub
					swipeLayout.setRefreshing(false);
//					dismissDialog();
				}

				@Override
				public void onSuccess(List<Tournament> dataList) {
					// TODO Auto-generated method stub
					swipeLayout.setRefreshing(false);
//					dismissDialog();
					LogUtil.i(TAG,"size:"+dataList.size());
					if(dataList.size()!=0){
//						data = dataList;
						if(mAdapter==null){
							mAdapter = new TournamentListAdapter(mContext, dataList,false);
							list.setAdapter(mAdapter);
						}else{
							mAdapter.setData(dataList);
						}
					}else{
						showToast("您暂时还没有比赛。");
					}
				}
			}, 500);
		}
		
		
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
				Intent intent = new Intent();
		    	intent.setClass(mContext, CompetitionInfoActivity.class);
		    	intent.putExtra("tournament", (Tournament)mAdapter.getItem(position));
		    	startActivity(intent);
			}
		});
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stubs
		super.onLeftMenuClick();
		finish();
	}

	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
		if(mUser!=null){
			updateSaicheng();
		}else{
			updateSaicheng2();
		}
		
	}
	
}
