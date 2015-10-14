package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ListView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.HomeTeamAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

/**
 * 选择主队
 */
public class ChooseHomeTeamActivity extends BaseActivity{

	ListView homeList;
	Button next;
	HomeTeamAdapter mAdapter;
	List<Team> teams = new ArrayList<Team>();
	User user ;
	int index ;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_choose_home_team);
		setUpAction(mActionBarTitle, "选择主队", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		user = BmobUser.getCurrentUser(mContext, User.class);
		queryNearbyTeams(new String[]{"captain"},new Object[]{user});
		homeList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				mAdapter.setSelectedItem(position);
				mAdapter.notifyDataSetChanged();
				index = position;
			}
		});
		next.setOnClickListener(this);
	}
	
	private void queryNearbyTeams(String[] keys,Object[] values) {
		// TODO Auto-generated method stub
		BmobQuery<Team> teamQuery = new BmobQuery<Team>();
		teamQuery.include("captain");
		if(keys!=null&&values!=null){
			for(int i=0;i<keys.length;i++){
				teamQuery.addWhereEqualTo(keys[i], values[i]);
			}
		}
		showToast("正在查询您的球队");
		teamQuery.findObjects(mContext, new FindListener<Team>() {
			
			@Override
			public void onSuccess(List<Team> data) {
				// TODO Auto-generated method stub
				if(data.size()!=0){
					teams = MyApplication.getInstance().getTeams();//data;
					if(mAdapter == null){
						mAdapter = new HomeTeamAdapter(mContext, teams);
						homeList.setAdapter(mAdapter);
					}else{
						mAdapter.setTeams(teams);
						mAdapter.notifyDataSetChanged();
					}
				}else{
                    //当队员创建球队的时候，需要查询出当前用户的加入的所有球队
                    TeamManager.getMyTeams(mContext,new FindListener<Team>() {
                        @Override
                        public void onSuccess(List<Team> datas) {
                            if(datas!=null && datas.size()>0){
                                //设置当前球队
                                MyApplication.getInstance().setTeams(datas);
                                teams = datas;
                                if(mAdapter == null){
                                    mAdapter = new HomeTeamAdapter(mContext, teams);
                                    homeList.setAdapter(mAdapter);
                                }else{
                                    mAdapter.setTeams(teams);
                                    mAdapter.notifyDataSetChanged();
                                }
                            }else{
                                ToastUtil.showToast(mContext, "你还没有加入过任何球队，快去加入吧!");
                            }
                        }

                        @Override
                        public void onError(int i, String s) {
                            ToastUtil.showToast(mContext, "你还没有加入过任何球队");
                        }
                    });
				}
			}
			
			@Override
			public void onError(int errorCode, String errorString) {
				// TODO Auto-generated method stub
				ToastUtil.showToast(mContext, "网络无法连接或信号不好");
			}
		});
	}
	
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.cp_hometeam_next:
			MyApplication.getInstance().getmTournament().setHome_court(teams.get(index));
			redictTo(mContext, ChooseOpponentTeamActivity.class, null);
			break;

		default:
			break;
		}
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		homeList = (ListView)contentView.findViewById(R.id.home_team_list);
		next = (Button)contentView.findViewById(R.id.cp_hometeam_next);
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}

}
