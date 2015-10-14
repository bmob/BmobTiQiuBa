package cn.bmob.zuqiu.ui;

import java.util.ArrayList;
import java.util.List;

import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.GradesAdapter;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.Comment;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class MyGradesActivity extends BaseActivity{
	
	private ListView gradesList;
	private GradesAdapter mAdapter;
	private List<Comment> data = new ArrayList<Comment>();
    private TextView gradesTips;
	
	private User user;
	String userName = "";
	private Tournament mTournament;
	private ImageView share;
	private PlayerScore score;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_my_grades);
		
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		user = BmobUser.getCurrentUser(mContext, User.class);
		mTournament = (Tournament) getIntent().getSerializableExtra("tournament");
		score = (PlayerScore)getIntent().getSerializableExtra("score");
		gradesList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				
			}
		});
		
		if(user.getNickname()!=null){
			userName = user.getNickname();
		}else{
			userName = user.getUsername();
		}
		setUpAction(mActionBarTitle, userName+"", 0, View.VISIBLE);
		gradesTips.setText("我的评分");
		getComment();
	}
	
	private void getComment(){
		BmobQuery<Comment> query = new BmobQuery<Comment>();
		query.addWhereEqualTo("competition", mTournament);
		query.addWhereEqualTo("accept_comm", user);
		query.include("accept_comm,komm,competition");
		query.setLimit(30);
		query.findObjects(mContext, new FindListener<Comment>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("无法获取评分数据，请检查网络");
			}

			@Override
			public void onSuccess(List<Comment> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>0){
					data = arg0;
					if(mAdapter==null){
						mAdapter = new GradesAdapter(mContext, data);
						gradesList.setAdapter(mAdapter);
					}else{
						mAdapter.setComments(arg0);
						mAdapter.notifyDataSetChanged();
					}
					
				}else{
					showToast("暂无评分数据。");
				}
			}
		});
	}

	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		gradesList = (ListView) contentView.findViewById(R.id.grades_team);
		gradesTips = (TextView)contentView.findViewById(R.id.grades_mine_tille);
		share = (ImageView)contentView.findViewById(R.id.my_share);
		share.setOnClickListener(this);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.report_share:
			if(score!=null&&mTournament!=null){
				ShareData data = new ShareData();
				data.setTitle("我的比赛数据");
				data.setText(user.getNickname()+"在"+mTournament.getName()+"比赛中进球"+score.getGoals()+
						"个，助攻"+score.getAssists()+"次，大家对"+user.getNickname()
						+"的综合评分是"+score.getAvg()+"分。"+ShareHelper.getCommentData(user.getObjectId(), mTournament.getObjectId()));
				data.setImageUrl(ShareHelper.iconUrl);
				data.setUrl(ShareHelper.getCommentData(user.getObjectId(), mTournament.getObjectId()));
				ShareHelper.share(MyGradesActivity.this, data);
			}
			break;

		default:
			break;
		}
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}

}
