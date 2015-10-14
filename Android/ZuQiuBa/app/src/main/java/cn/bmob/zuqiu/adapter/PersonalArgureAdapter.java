package cn.bmob.zuqiu.adapter;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.CloudCodeListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.GradesActivity;
import cn.bmob.zuqiu.utils.CloudCode;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class PersonalArgureAdapter extends BaseAdapter{

	private Context mContext;
	private List<PlayerScore> data = new ArrayList<PlayerScore>();
	private User user;
    private Team team;
	
	public PersonalArgureAdapter(Context mContext, List<PlayerScore> data, Team t) {
		super();
		this.mContext = mContext;
		this.data = data;
		this.user = BmobUser.getCurrentUser(mContext, User.class);
        this.team = t;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return data.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return data.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		ViewHolder viewHolder = null;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_cp_personal_argues, null);
			viewHolder.shotAndPass = (LinearLayout)convertView.findViewById(R.id.shot_and_pass);
			viewHolder.playerShot = (TextView) convertView.findViewById(R.id.personal_argure_shot);
			viewHolder.playerPass = (TextView)convertView.findViewById(R.id.personal_argure_pass);
			viewHolder.playerName = (TextView)convertView.findViewById(R.id.personal_name);
			viewHolder.playerAvg = (TextView)convertView.findViewById(R.id.personal_avg);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		final PlayerScore score = data.get(position);
		if(score.getGoals()==null&&score.getAssists()==null){
			viewHolder.shotAndPass.setBackgroundResource(R.drawable.bg_cp_personal_argure_none);
			viewHolder.playerShot.setText("");
			viewHolder.playerPass.setText("");
		}else{
			viewHolder.shotAndPass.setBackgroundResource(R.drawable.bg_cp_personal_argures);
			viewHolder.playerShot.setText(score.getGoals() == null ? "0" : score.getGoals()+"");
			viewHolder.playerPass.setText(score.getAssists() == null ? "0" : score.getAssists()+"");
		}
		final User user = score.getPlayer();
		if(user.getNickname()!=null){
			viewHolder.playerName.setText(user.getNickname());
		}else{
			viewHolder.playerName.setText(user.getUsername());
		}
		
		viewHolder.playerAvg.setText(score.getAvg()+"");
        viewHolder.playerAvg.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                Intent intent = new Intent();
                intent.setClass(mContext, GradesActivity.class);
                intent.putExtra("score", data.get(position));
                mContext.startActivity(intent);

            }
        });
		viewHolder.shotAndPass.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Tournament mTournament = data.get(position).getCompetition();
//				if(!TeamManager.isCaptain(mTournament.getHome_court(), user)
//						||!TeamManager.isCaptain(mTournament.getOpponent(), user)){
//					return;
//				}

                if(TeamManager.isCaptain(team, BmobUser.getCurrentUser(mContext, User.class))){//是队长就可以编辑
                    if(mTournament.isVerify()){
                        Toast.makeText(mContext, "赛事已通过认证，不能再编辑了", Toast.LENGTH_SHORT).show();
                    }else{
                        showEditDialog(data.get(position));
                    }
                }

			}
		});

		return convertView;
	}

	class ViewHolder{
		LinearLayout shotAndPass;
		TextView playerShot;
		TextView playerPass;
		TextView playerName;
		TextView playerAvg;
	}
	
	
	Dialog timeDialog = null;
	private void showEditDialog(final PlayerScore score){
		if(timeDialog == null){
			timeDialog = new AlertDialog.Builder(mContext).create();
		}
		timeDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(mContext).inflate(
				R.layout.dialog_edit_member_argue, null);
		timeDialog.show();
		timeDialog.setContentView(view);
		timeDialog.getWindow().setGravity(Gravity.CENTER);
		timeDialog.getWindow().setLayout(
				((Activity)mContext).getWindowManager().getDefaultDisplay().getWidth()-30,
				android.view.WindowManager.LayoutParams.WRAP_CONTENT);
		//解决键盘无法弹出的问题
		timeDialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
//		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
		TextView editTitle = (TextView)view.findViewById(R.id.edit_title);
		if(score.getPlayer().getNickname()!=null){
			editTitle.setText("编辑球员 "+score.getPlayer().getNickname()+" 的数据");
		}else{
			editTitle.setText("编辑球员 "+score.getPlayer().getUsername()+" 的数据");
		}
		final EditText goalsInput = (EditText)view.findViewById(R.id.goals_input);
		goalsInput.setText(score.getGoals() == null ? "" : score.getGoals() +"");
		goalsInput.requestFocus();
		goalsInput.requestFocusFromTouch();
//		showSoftInput(goalsInput);

		final EditText assistsInput = (EditText)view.findViewById(R.id.assists_input);
		assistsInput.setText(score.getAssists() == null ? "" : score.getAssists()+"");
		TextView editCancel = (TextView)view.findViewById(R.id.edit_cancel);
		TextView editOk = (TextView)view.findViewById(R.id.edit_ok);
		editCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
//				hideSoftInput();
				if(timeDialog!=null&&timeDialog.isShowing()){
					timeDialog.dismiss();
				}
			}
		});
		editOk.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				String goals = goalsInput.getText().toString().trim();
				if(TextUtils.isEmpty(goals)){
					ToastUtil.showToast(mContext, "请输入进球数");
					return;
				}
				String assists = assistsInput.getText().toString().trim();
				if(TextUtils.isEmpty(assists)){
					ToastUtil.showToast(mContext, "请输入助攻数");
					return;
				}
				score.setGoals(Integer.parseInt(goals));
				score.setAssists(Integer.parseInt(assists));
				score.update(mContext, new UpdateListener() {
					
					@Override
					public void onSuccess() {
						// TODO Auto-generated method stub
						ToastUtil.showToast(mContext, "修改数据成功");
						if(timeDialog!=null&&timeDialog.isShowing()){
							timeDialog.dismiss();
						}
						notifyDataSetChanged();
						CloudCode.userGoalAssist(mContext, score.getPlayer().getObjectId(), new CloudCodeListener() {
							
							@Override
							public void onSuccess(Object arg0) {
								// TODO Auto-generated method stub
								LogUtil.i("adapter","统计用户数据成功。"+arg0.toString());
							}
							
							@Override
							public void onFailure(int arg0, String arg1) {
								// TODO Auto-generated method stub
								LogUtil.i("adapter","统计用户数据成功。"+arg0+arg1);
							}
						});
					}
					
					@Override
					public void onFailure(int arg0, String arg1) {
						// TODO Auto-generated method stub
						ToastUtil.showToast(mContext, "修改数据失败。请检查网络");
						if(timeDialog!=null&&timeDialog.isShowing()){
							timeDialog.dismiss();
						}
					}
				});
			}
		});
	}
}
