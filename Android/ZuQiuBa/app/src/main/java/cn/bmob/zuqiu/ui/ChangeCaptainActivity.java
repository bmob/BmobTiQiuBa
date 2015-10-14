package cn.bmob.zuqiu.ui;

import java.util.ArrayList;
import java.util.List;

import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.ChangeCaptainAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;
/**
 * 更换队长
 * @author venus
 *
 */
public class ChangeCaptainActivity extends BaseActivity{
	
	private ListView memberList;
	private List<User> listData = new ArrayList<User>();
	private ChangeCaptainAdapter mAdapter;
	
	private Team currentTeam;
	private int index;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarTitle, "更换队长", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
		
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
						mAdapter = new ChangeCaptainAdapter(mContext, list);
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
		initProgressDialog(R.string.team_changcaptain_tips);
		TeamManager.changeCaptain(mContext, currentTeam, listData.get(index), new UpdateListener() {
			
			@Override
			public void onSuccess() {
				// TODO Auto-generated method stub
				dismissDialog();
				showToast("更换队长成功");
				Bundle bundle = new Bundle();
				bundle.putSerializable("user", listData.get(index));
				setResult(RESULT_OK, ChangeCaptainActivity.this.getIntent().putExtras(bundle));
				ChangeCaptainActivity.this.finish();
			}
			
			@Override
			public void onFailure(int arg0, String arg1) {
				// TODO Auto-generated method stub
				dismissDialog();
				showToast("更换队长失败");
			}
		});
	}
}
