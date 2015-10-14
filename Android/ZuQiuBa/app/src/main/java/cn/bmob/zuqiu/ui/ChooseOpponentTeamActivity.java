package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
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
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

/**
 * 选择对手
 */
public class ChooseOpponentTeamActivity extends BaseActivity{

	ListView homeList;
	Button next;
	ImageButton searchTeam;
	EditText teamInput;
	HomeTeamAdapter mAdapter;
	List<Team> teams = new ArrayList<Team>();
	User user ;
	int index ;
	String searchContent;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_choose_opponent_team);
		setUpAction(mActionBarTitle, "选择对手", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		hideKeyBoard();
		user = BmobUser.getCurrentUser(mContext, User.class);
		queryNearbyTeams(null,null);
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
		searchTeam.setOnClickListener(this);
	}
	
	private void queryNearbyTeams(String[] keys,String[] values) {
		// TODO Auto-generated method stub
		BmobQuery<Team> teamQuery = new BmobQuery<Team>();
		teamQuery.include("captain");
		if(keys!=null&&values!=null){
			for(int i=0;i<keys.length;i++){
				teamQuery.addWhereContains(keys[i], values[i]);
			}
		}
		showToast("正在查询球队");
		teamQuery.findObjects(mContext, new FindListener<Team>() {
			
			@Override
			public void onSuccess(List<Team> data) {
				// TODO Auto-generated method stub
				if(data.size()!=0){
					teams = data;
					if(mAdapter == null){
						mAdapter = new HomeTeamAdapter(mContext, data);
						homeList.setAdapter(mAdapter);
					}else{
						mAdapter.setTeams(data);
						mAdapter.notifyDataSetChanged();
					}
				}else{
					ToastUtil.showToast(mContext, "没有合适条件的球队");
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
            //客队
			MyApplication.getInstance().getmTournament().setOpponent(teams.get(index));
            //比赛名
			MyApplication.getInstance().getmTournament().setName(MyApplication.getInstance().getmTournament().getHome_court().getName()
					+"-"+MyApplication.getInstance().getmTournament().getOpponent().getName());
            if(TeamManager.isCaptain(MyApplication.getInstance().getmTournament().getHome_court(), getUser())){//如果当前用户是队长，则给对方球队的队长发送约赛消息
                // 是队长
                showToast("比赛邀请发送成功，请等待对方确认");
                sendOpponentCaptainMessage();
            }else{
                showToast("已向队长发送通知");
                sendMyCaptainMessage();
            }
            MyApplication.getInstance().setmTournament(null);

            Intent intent  = new Intent();
            intent.setClass(mContext, MainActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            startActivity(intent);
            
			break;
		case R.id.search_team:
			searchContent = teamInput.getText().toString().trim();
			if(TextUtils.isEmpty(searchContent)){
				ToastUtil.showToast(mContext,getString(R.string.search_input_tips));
				return;
			}
			queryNearbyTeams(new String[]{"name"}, new String[]{searchContent});
			hideSoftInput(teamInput);
			break;
		default:
			break;
		}
	}

    /**
     * 发送创建赛事成功的信息给对方队长
     */
    private void sendOpponentCaptainMessage(){
        Tournament tour =MyApplication.getInstance().getmTournament();//内存中的比赛
        //组装发给对方队长的消息
        PushMessage msg = PushMessageHelper.createGame2Opponent(this,tour);
        //发送给客队队长
        MyApplication.getInstance().getPushHelper2().push2User(tour.getOpponent().getCaptain(),msg);
    }

    /**
     * 发送创建赛事的消息给本队队长
     */
    private void sendMyCaptainMessage(){
        //队友队员A申请XX月XX日与球队B在XX地点比赛。
        Tournament tour =MyApplication.getInstance().getmTournament();//内存中的比赛
        //组装发给本队队长的消息
        PushMessage msg = PushMessageHelper.createGame2MyCaptionByMember(this,tour);
        MyApplication.getInstance().getPushHelper2().push2User(tour.getHome_court().getCaptain(),msg);
    }
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		homeList = (ListView)contentView.findViewById(R.id.home_team_list);
		next = (Button)contentView.findViewById(R.id.cp_hometeam_next);
		searchTeam = (ImageButton)contentView.findViewById(R.id.search_team);
        teamInput = (EditText)contentView.findViewById(R.id.search_team_input);
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}

}
