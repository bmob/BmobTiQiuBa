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
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.MemberListAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class TeamMemberActivity extends BaseActivity{
	private ListView memberList;
	private List<User> listData = new ArrayList<User>();
	private MemberListAdapter mAdapter;
	
	private Team currentTeam;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarTitle, "成员管理", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.selector_add_friend, View.VISIBLE);
		
		setViewContent(R.layout.activity_sigle_choice);
		currentTeam = (Team) getIntent().getSerializableExtra("team");
		getTeamMembers(currentTeam);
	}
	
	private void getTeamMembers(Team team) {
		// TODO Auto-generated method stub
		if(team ==null){
			return;
		}
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo("footballer", new BmobPointer(team));
		query.findObjects(mContext, new FindListener<User>() {
			
			@Override
			public void onSuccess(List<User> list) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG,"size:"+list.size());
				if(list.size()!=0){
					listData = list;
					if(mAdapter==null){
						mAdapter = new MemberListAdapter(mContext, list,currentTeam);
						memberList.setAdapter(mAdapter);
					}else{
						mAdapter.setData(list);
					}
				}else{
				}
			}
			
			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
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
                Bundle bundle = new Bundle();
                bundle.putSerializable("user", listData.get(position));
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
		Intent intent = new Intent();
		intent.setClass(mContext, AddMemberActivity.class);
		intent.putExtra("team", currentTeam);
		startActivity(intent);
	}

}
