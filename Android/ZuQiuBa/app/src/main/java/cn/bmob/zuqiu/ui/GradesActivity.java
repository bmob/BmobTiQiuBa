package cn.bmob.zuqiu.ui;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.CloudCodeListener;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.GradesAdapter;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.CloudCode;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.Comment;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.User;
/**
 * 给球员的评分
 *
 * */
public class GradesActivity extends BaseActivity{
	
	private ListView gradesList;
	private GradesAdapter mAdapter;
	private List<Comment> data = new ArrayList<Comment>();
    private TextView gradesPoints;
    private EditText gradesContent;
    private TextView gradesTips;
    private TextView gradesTitle;
	private String[] points = {"1","2","3","4","5","6","7","8","9","10"};
	
	private User user;
	private PlayerScore score;
	String userName = "";
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_grades);
		
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
		user = BmobUser.getCurrentUser(mContext, User.class);
		score = (PlayerScore) getIntent().getSerializableExtra("score");
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		
//		Comment cm = new Comment();
//		cm.setAccept_comm(user);
//		cm.setScore(7);
//		cm.setComment("踢得好");
//		data.add(cm);
//		
//		Comment cm2 = new Comment();
//		cm2.setAccept_comm(user);
//		cm2.setScore(7);
//		cm2.setComment("踢得好");
//		data.add(cm2);
//		mAdapter = new GradesAdapter(mContext, data);
//		gradesList.setAdapter(mAdapter);
		gradesList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				
			}
		});
		
		gradesPoints.setOnClickListener(this);
		
		User user = score.getPlayer();
		if(user.getNickname()!=null){
			userName = user.getNickname();
		}else{
			userName = user.getUsername();
		}
		setUpAction(mActionBarTitle, userName+"", 0, View.VISIBLE);
		gradesTips.setText("根据"+userName+"本场比赛的表现，你对他的评分");
		gradesTitle.setText(userName+"本场比赛获得的比分");
        getMyComments();
		getComment();
	}

    Comment comment;
    private void getMyComments(){
        BmobQuery<Comment> query = new BmobQuery<Comment>();
        query.addWhereEqualTo("komm", user);
        query.addWhereEqualTo("competition",score.getCompetition());
        query.findObjects(this, new FindListener<Comment>() {
            @Override
            public void onSuccess(List<Comment> comments) {
                if(comments.size()>0){
                    comment = comments.get(0);
                    gradesPoints.setText(comment.getScore()+"");
                    gradesContent.setText(comment.getComment());
                }
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }

	
	private void getComment(){
		BmobQuery<Comment> query = new BmobQuery<Comment>();
		query.addWhereEqualTo("competition", score.getCompetition());
		query.addWhereEqualTo("accept_comm", score.getPlayer());
        query.addWhereNotEqualTo("komm", user);
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
		gradesPoints = (TextView)contentView.findViewById(R.id.grades_point);
		
		gradesContent = (EditText)contentView.findViewById(R.id.gradeds_comment);
		gradesTips = (TextView)contentView.findViewById(R.id.grades_tips);
		gradesTitle = (TextView)contentView.findViewById(R.id.grades_mine_tille);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.grades_point:
			
			showPointDialog();
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
	
	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
//		Comment comment = new Comment();
        if(comment == null) {
            comment = new Comment();
            comment.setAccept_comm(score.getPlayer());
            comment.setKomm(user);
            String content = gradesContent.getText().toString().trim();
            if (!TextUtils.isEmpty(content)) {
                comment.setComment(content);
            }
            comment.setScore(Integer.parseInt(gradesPoints.getText().toString()));
            comment.setCompetition(score.getCompetition());
            comment.save(mContext, new SaveListener() {

                @Override
                public void onSuccess() {
                    // TODO Auto-generated method stub
                    showToast("评分成功。");
                    getComment();
                    CloudCode.commentScore(mContext, score.getPlayer().getObjectId(), new CloudCodeListener() {

                        @Override
                        public void onSuccess(Object arg0) {
                            // TODO Auto-generated method stub
                            LogUtil.i("adapter", "统计平均分成功" + arg0.toString());
                        }

                        @Override
                        public void onFailure(int arg0, String arg1) {
                            // TODO Auto-generated method stub
                            LogUtil.i("adapter", "统计平均分失败" + arg0 + arg1);
                        }
                    });
                    finish();
                }

                @Override
                public void onFailure(int arg0, String arg1) {
                    // TODO Auto-generated method stub
                    showToast("评分失败，请检查网络。");
                }
            });
        }else{
            comment.setAccept_comm(score.getPlayer());
            comment.setKomm(user);
            String content = gradesContent.getText().toString().trim();
            if (!TextUtils.isEmpty(content)) {
                comment.setComment(content);
            }
            comment.setScore(Integer.parseInt(gradesPoints.getText().toString()));
            comment.setCompetition(score.getCompetition());
            comment.update(this, new UpdateListener() {
                @Override
                public void onSuccess() {
                    showToast("评分成功。");
                    finish();
                }

                @Override
                public void onFailure(int i, String s) {

                }
            });
        }
	}
	
	Dialog timeDialog = null;
	private void showPointDialog(){
		if(timeDialog == null){
			timeDialog = new AlertDialog.Builder(mContext).create();
		}
		timeDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(mContext).inflate(
				R.layout.dialog_choose_point, null);
		timeDialog.show();
		timeDialog.setContentView(view);
		timeDialog.getWindow().setGravity(Gravity.BOTTOM);
		timeDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth(),
				getWindowManager().getDefaultDisplay().getHeight()/2);
		ListView list = (ListView)view.findViewById(R.id.point_list);
		list.setAdapter(
				new ArrayAdapter<String>(mContext, R.layout.item_a_text, R.id.point_num, points));
		list.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				gradesPoints.setText(points[position]);
				if(timeDialog!=null&&timeDialog.isShowing()){
					timeDialog.dismiss();
				}
			}
		});
	}
}
