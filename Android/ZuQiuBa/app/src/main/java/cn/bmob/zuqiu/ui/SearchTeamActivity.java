package cn.bmob.zuqiu.ui;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobQuery.CachePolicy;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.FriendListAdapter;
import cn.bmob.zuqiu.adapter.NearbyTeamAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class SearchTeamActivity extends BaseActivity{
	ListView nearTeamList;
	NearbyTeamAdapter mAdapter;
	String searchContent;
	List<Team> dataList = new ArrayList<Team>();
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarTitle, "搜索球队", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setViewContent(R.layout.activity_search_team);
		
		nearTeamList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				Bundle bundle = new Bundle();
				bundle.putSerializable("team", dataList.get(position));
				Intent intent = new Intent();
				intent.setClass(mContext, OtherTeamInfoActivity.class);
				intent.putExtra("data", bundle);
				startActivity(intent);
			}
		});
		
		searchContent =getIntent().getStringExtra("search_content");
		queryNearbyTeams(new String[]{"name"}, new String[]{searchContent});
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		nearTeamList = (ListView)contentView.findViewById(R.id.nearby_team_list);
	}
	
	private void queryNearbyTeams(String[] keys,String[] values) {
		// TODO Auto-generated method stub
		if(keys.length==0||values.length==0){
			return;
		}
		BmobQuery<Team> teamQuery = new BmobQuery<Team>();
		teamQuery.include("captain");
		if(keys!=null&&values!=null){
			for(int i=0;i<keys.length;i++){
				teamQuery.addWhereContains(keys[i], values[i]);
			}
		}
		showToast("正在搜索球队...");
		teamQuery.findObjects(mContext, new FindListener<Team>() {
			
			@Override
			public void onSuccess(List<Team> data) {
				// TODO Auto-generated method stub
				if(data.size()!=0){
					dataList = data;
					if(mAdapter == null){
						mAdapter = new NearbyTeamAdapter(mContext, data);
						nearTeamList.setAdapter(mAdapter);
					}else{
						mAdapter.setTeams(data);
						mAdapter.notifyDataSetChanged();
					}
					ToastUtil.showToast(mContext, "找到"+data.size()+"支球队。");
				}else{
					ToastUtil.showToast(mContext, "没有找到你要找的球队。");
				}
			}
			
			@Override
			public void onError(int errorCode, String errorString) {
				// TODO Auto-generated method stub
				
			}
		});
	}

	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
}
