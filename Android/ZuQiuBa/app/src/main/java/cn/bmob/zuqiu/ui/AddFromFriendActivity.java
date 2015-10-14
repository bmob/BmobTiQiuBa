package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.AddFromFriendAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.UserManager;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class AddFromFriendActivity extends BaseActivity{

	private ListView memberList;
	private List<User> listData = new ArrayList<User>();
	private AddFromFriendAdapter mAdapter;
	
	private int index;
	private UserManager manager;
	private Team currentTeam;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarTitle, "添加队友", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
		
		setViewContent(R.layout.activity_sigle_choice);
		manager = new UserManager(mContext);
		currentTeam = (Team) getIntent().getSerializableExtra("team");
		getFriend();
	}
	
	private void getFriend(){
		initProgressDialog(R.string.loading);
		manager.getFriend(new FindListener<User>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				dismissDialog();
				showToast("请检查网络。");
			}

			@Override
			public void onSuccess(List<User> list) {
				// TODO Auto-generated method stub
				dismissDialog();
				LogUtil.i(TAG,"size:"+list.size());
				if(list.size()!=0){
					listData = list;
					if(mAdapter==null){
						mAdapter = new AddFromFriendAdapter(mContext,list);
						memberList.setAdapter(mAdapter);
					}else{
						mAdapter.setData(list);
					}
				}else{
					showToast("您还没有好友，赶紧去加一个吧");
				}
			}
		});
	}

	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		memberList = (ListView)contentView.findViewById(R.id.list_view);
		memberList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				mAdapter.setSelectedItem(position);
				mAdapter.notifyDataSetChanged();
				index = position;
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
        //邀请加入球队
		PushMessage msg = PushMessageHelper.inviteByCaptainMessage(this,currentTeam);
        MyApplication.getInstance().getPushHelper2().push2User(listData.get(index),msg);
		showToast("已发送邀请");
	}
}
