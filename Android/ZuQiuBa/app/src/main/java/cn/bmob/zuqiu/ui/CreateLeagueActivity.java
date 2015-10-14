package cn.bmob.zuqiu.ui;


import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.User;

public class CreateLeagueActivity extends BaseActivity{
	
	
	private EditText leagueNameInput;
	private EditText leaguePeopleInput;
	private EditText leagueGroupInput;
	private Button nextStep;
	
	private String leagueName;
	private String leaguePeople;
	private String leagueGroup;
	
    private boolean isCreateLeague = false;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_create_league);
		setUpAction(mActionBarTitle, "创建联赛", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);

        findMyCreateLeague();
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		leagueNameInput = (EditText)contentView.findViewById(R.id.league_name_content);
		leaguePeopleInput = (EditText)contentView.findViewById(R.id.league_people_content);
		leagueGroupInput = (EditText)contentView.findViewById(R.id.league_group_content);
		nextStep = (Button)contentView.findViewById(R.id.league_next_step);
		
		nextStep.setOnClickListener(this);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.league_next_step:
			
			leagueName = leagueNameInput.getText().toString().trim();
			if(TextUtils.isEmpty(leagueName)){
				showToast("联赛名称不能为空...");
				return;
			}
			leaguePeople = leaguePeopleInput.getText().toString().trim();
			if(TextUtils.isEmpty(leaguePeople)){
				showToast("上场人数不能为空...");
				return;
			}else{
				if(!TextUtils.isDigitsOnly(leaguePeople)){
					showToast("请输入数字...");
					return;
				}
			}
			leagueGroup = leagueGroupInput.getText().toString().trim();
			if(TextUtils.isEmpty(leagueGroup)){
				showToast("小组数量不能为空...");
				return;
			}else{
				if(!TextUtils.isDigitsOnly(leagueGroup)){
					showToast("请输入数字...");
					return;
				}
			}
            
            if(isCreateLeague){
                // 如果创建过联赛，给予提示
//                showToast("您已创建过联赛，再次创建联赛将失去上一个联赛管理权限，是否继续？");
                new AlertDialog.Builder(this)
                        .setTitle("提示")
                        .setMessage("您已创建过联赛，再次创建联赛将失去上一个联赛管理权限，是否继续？")
                        .setPositiveButton("继续",new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                createLeague(leagueName, leaguePeople, leagueGroup);
                                hideSoftInput(leagueGroupInput);
                            }
                        })
                        .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                            }
                        }).create().show();
            }else{
                createLeague(leagueName, leaguePeople, leagueGroup);
                hideSoftInput(leagueGroupInput);
            }
			break;

		default:
			break;
		}
	}
    
    private void findMyCreateLeague(){
        BmobQuery<League> query = new BmobQuery<League>();
        query.addWhereEqualTo("master", BmobUser.getCurrentUser(this, User.class));
        query.findObjects(this, new FindListener<League>() {
            @Override
            public void onSuccess(List<League> leagues) {
                if(leagues.size()>0){
                    isCreateLeague = true;
                }
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }
	
	private void createLeague(final String name,String number,String group){
		League league = new League();
		league.setName(name);
		league.setMaster(getUser());
		league.setPeople(Integer.parseInt(number));
		league.setGroup_count(Integer.parseInt(group));
		league.setCity("");
		league.setKnockout(false);
		league.setNotes(name);
		initProgressDialog(R.string.league_loading_tips);
		league.save(mContext, new SaveListener() {
			
			@Override
			public void onSuccess() {
				// TODO Auto-generated method stub
				dismissDialog();
				showToast("创建联赛成功");
				Bundle bundle = new Bundle();
				bundle.putString("name", name);
				redictTo(mContext, CreateLeagueResultActivity.class, bundle);
				finish();
			}
			
			@Override
			public void onFailure(int errorCode, String errorString) {
				// TODO Auto-generated method stub
				dismissDialog();
				showToast("创建联赛失败");
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
