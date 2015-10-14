package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.SearchLeagueAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.Team;
/*
* 参与的联赛
* */
public class LeagueRecordActivity extends BaseActivity{

	private ListView leagueList;

	private List<League> leagueData = new ArrayList<League>();

	private SearchLeagueAdapter mAdapter;

	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_league_record);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarTitle, "参与的联赛", 0, View.VISIBLE);
//        leagueData = (List<League>) getIntent().getSerializableExtra("MyLeagues");
		getLeague();
        mAdapter = new SearchLeagueAdapter(mContext, leagueData);
        leagueList.setAdapter(mAdapter);
        leagueList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				Intent intent = new Intent();
				intent.setClass(LeagueRecordActivity.this, LeagueDetailActivity.class);
			    intent.putExtra("league", leagueData.get(position));
				startActivity(intent);
			}
		});
	}

	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		leagueList = (ListView)contentView.findViewById(R.id.league_record_list);
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}

    /**
	 * 获取我正在参加的比赛
	 */
	private void getLeague(){
		if(MyApplication.getInstance().getCurrentTeam()==null){
			LogUtil.i(TAG,"TEAM IS NULL");
			return;
		}
		initProgressDialog(R.string.loading);
		BmobQuery<League> query = new BmobQuery<League>();
		BmobQuery<Team> innerQuery = new BmobQuery<Team>();
		innerQuery.addWhereEqualTo("objectId", MyApplication.getInstance().getCurrentTeam().getObjectId());
		query.addWhereMatchesQuery("teams", "Team", innerQuery);
		query.order("-createdAt");
		query.setLimit(500);
		query.findObjects(LeagueRecordActivity.this, new FindListener<League>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				dismissDialog();
				LogUtil.i("league", "not FINDED:"+arg0+arg1);
			}

			@Override
			public void onSuccess(List<League> arg0) {
				// TODO Auto-generated method stub
				LogUtil.i("league", "FINDED:"+arg0.size());
				dismissDialog();
				if(arg0!=null&&arg0.size()>0){
					leagueData = arg0;
					mAdapter = new SearchLeagueAdapter(mContext, arg0);
					leagueList.setAdapter(mAdapter);
				}else{
                    showToast("你还没有参加过联赛哦！");
				}
			}
		});

	}

}
