package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.FriendListAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.User;
/**
 * 好友列表
 * @author venus
 *
 */
public class FriendListActivity extends BaseActivity{
	private ListView friendList;
	private TextView emptyView;
	private List<User> userList = new ArrayList<User>();
	private FriendListAdapter mAdapter;
	private User mUser;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_friend_list);
		setUpAction(mActionBarTitle, getString(R.string.friend_list), 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.selector_add_friend, View.VISIBLE);
		mUser = BmobUser.getCurrentUser(mContext, User.class);
		getFriends(mUser);
	}
	
	private void getFriends(User mUser) {
		if(mUser == null){
			return;
		}
		initProgressDialog(R.string.loading);
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo("friends", new BmobPointer(mUser));
		query.setLimit(500);
//		query.setCachePolicy(CachePolicy.CACHE_THEN_NETWORK);
		query.findObjects(mContext, new FindListener<User>() {
			
			@Override
			public void onSuccess(List<User> list) {
				// TODO Auto-generated method stub
				dismissDialog();
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
//					showToast("您暂时还没有好友");
				}
			}
			
			@Override
			public void onError(int errorCode, String errorString) {
				// TODO Auto-generated method stub
				dismissDialog();
			}
		});
	}

	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		friendList = (ListView)contentView.findViewById(R.id.friends_list);
		emptyView = (TextView)contentView.findViewById(R.id.emptyview);
		friendList.setEmptyView(emptyView);
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
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
	
	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
		redictTo(mContext, AddFriendActivity.class, null);
	}
}
