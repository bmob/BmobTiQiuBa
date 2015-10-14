package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiu.utils.CompetitionManager;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class LeagueSaichengFragment extends BaseFragment implements OnRefreshListener{

	private List<Tournament> data = new ArrayList<Tournament>();
	
	private ListView list;
	private TournamentListAdapter mAdapter;
	private User mUser;
	private CompetitionManager manager;
	private TextView emptyView;
	private TextView timeYear;
	private SwipeRefreshLayout swipeLayout;
	
	public static LeagueSaichengFragment getInstance(int pos){
		LeagueSaichengFragment jifen = new LeagueSaichengFragment();
		return jifen;
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		mUser = BmobUser.getCurrentUser(getActivity(), User.class);
		manager = new CompetitionManager(getActivity());
	}
	
	@Override
	public void onAttach(Activity activity) {
		// TODO Auto-generated method stub
		super.onAttach(activity);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		return inflater.inflate(R.layout.activity_near_competition, null);
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onViewCreated(view, savedInstanceState);
		timeYear = (TextView)view.findViewById(R.id.time_year);
		list = (ListView)view.findViewById(R.id.competition_list);
		emptyView = (TextView)view.findViewById(R.id.empty_competiton);
		list.setEmptyView(emptyView);
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
				
			}
		});
		timeYear.setText(TimeUtils.getCurrentYear()+"年");
		getLeagueSaicheng();
	}
	
	private void getLeagueSaicheng(){
		swipeLayout.setRefreshing(true);
		manager.getLeagueSaiCheng(MyApplication.getInstance().getCurrentLeague(), 100, new FindListener<Tournament>() {
			
			@Override
			public void onSuccess(List<Tournament> dataList) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
				LogUtil.i(TAG,"size:"+dataList.size());
				if(dataList.size()!=0){
					if(mAdapter==null){
						mAdapter = new TournamentListAdapter(getActivity(), dataList,true);
						list.setAdapter(mAdapter);
					}else{
						mAdapter.setData(dataList);
					}
				}else{
//					showToast("您暂时还没有比赛。");
				}
			}
			
			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				swipeLayout.setRefreshing(false);
				
			}
		});
	}

	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
		getLeagueSaicheng();
	}
}
