package cn.bmob.zuqiu.ui;

import java.util.ArrayList;
import java.util.List;

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
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.User;

public class SearchMemberActivity extends BaseActivity{
	private ListView friendList;
	private List<User> userList = new ArrayList<User>();
	private FriendListAdapter mAdapter;
	
	private String searchContent;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarTitle, "添加队友", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setViewContent(R.layout.activity_search_friend);
		
		friendList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				Bundle bundle = new Bundle();
				bundle.putSerializable("user", userList.get(position));
				redictTo(mContext, PersonalInfoActivity.class, bundle);
			}
		});
		
		searchContent =getIntent().getStringExtra("search_content");
		getFriends(searchContent);
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		friendList = (ListView)contentView.findViewById(R.id.search_friend_list);
	}
	
	private void getFriends(String name) {
		if(name == null){
			return;
		}
		BmobQuery<User> queryUserName = new BmobQuery<User>();
		queryUserName.addWhereContains("username", searchContent);
		
		BmobQuery<User> queryNickName = new BmobQuery<User>();
		queryNickName.addWhereContains("nickname", searchContent);
		
		List<BmobQuery<User>> queries = new ArrayList<BmobQuery<User>>();
		queries.add(queryUserName);
		queries.add(queryNickName);
		
		BmobQuery<User> totalQuery = new BmobQuery<User>();
		totalQuery.or(queries);
		totalQuery.setCachePolicy(CachePolicy.CACHE_THEN_NETWORK);
		totalQuery.findObjects(mContext, new FindListener<User>() {
			
			@Override
			public void onSuccess(List<User> list) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG,"size:"+list.size());
				if(list.size()!=0){
					userList = list;
					if(mAdapter==null){
						mAdapter = new FriendListAdapter(mContext, list);
						friendList.setAdapter(mAdapter);
					}else{
						mAdapter.setData(list);
					}
				}else{
					showToast("没有符合条件的用户。");
				}
			}
			
			@Override
			public void onError(int errorCode, String errorString) {
				// TODO Auto-generated method stub
				showToast("请检查网络。");
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
