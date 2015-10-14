package cn.bmob.zuqiu.ui;




import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.baidu.android.pushservice.PushConstants;
import com.baidu.android.pushservice.PushManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

import cn.bmob.v3.AsyncCustomEndpoints;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobRelation;
import cn.bmob.v3.listener.CloudCodeListener;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.ResetPasswordListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushHelper2;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class IdentifyingActivity extends BaseActivity{

	private TextView identifyTimeTips;
	private EditText identifyCodeInput;
	private Button identifyCommit;
	
	private String identifyType;
	private String phoneNumer;
	private String password;
	private String inviteCode;
	private String identifyCodeFromMsg;
	private String identifyCodeFromCloud;
	private User mUser;//获取要改密码的用户
	
	private TimeCountDown timer;
	private static final int SECONDS_COUNT = 300;
	
	@Override
	protected void onCreate(Bundle saveInstance) {
		// TODO Auto-generated method stub
		super.onCreate(saveInstance);
		setViewContent(R.layout.activity_identify);
		//find back identify
        if(getIntent().getStringExtra("identify_type")!=null){
            identifyType = getIntent().getStringExtra("identify_type");
            phoneNumer = getIntent().getStringExtra("phone");
            mUser = (User) getIntent().getSerializableExtra("user");
        }
        if(!TextUtils.isEmpty(identifyType)&&identifyType.equals("find_password")){
            setUpAction(mActionBarTitle, getString(R.string.modify_findback), 0, View.VISIBLE);
            getIdentifyCodeForResetPassword(phoneNumer);
//            getIdentifyCodeForRegister(phoneNumer);
        }else{
            setUpAction(mActionBarTitle, getString(R.string.register), 0, View.VISIBLE);
            Bundle bundle = getIntent().getBundleExtra("data");
    		phoneNumer = bundle.getString("phone_number");
    		password = bundle.getString("password");
    		LogUtil.i("IdentifyActivity","phone:"+phoneNumer);
    		inviteCode = bundle.getString("invite_code");
    		getIdentifyCodeForRegister(phoneNumer);
        }
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		
		timer = new TimeCountDown(SECONDS_COUNT*1000, 1000);
		
		timer.start();
	}


		private void getIdentifyCodeForRegister(String phonenumber){

            //test
//            identifyCodeFromCloud = "123456";
//            return;

//            BmobUser.resetPasswordByPhone(this,phonenumber,new ResetPasswordListener() {
//                @Override
//                public void onSuccess() {
//                    Log.d("bmob","resetPasswordByPhone 调用成功");
//                }
//
//                @Override
//                public void onFailure(int i, String s) {
//                    Log.d("bmob","resetPasswordByPhone 调用失败");
//                }
//            });



			AsyncCustomEndpoints ace = new AsyncCustomEndpoints();

			JSONObject params = new JSONObject();
			try {
				params.put("mobile", phonenumber);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			ace.callEndpoint(mContext, "getMsgCode", params, new CloudCodeListener() {

				@Override
				public void onSuccess(Object object) {
					// TODO Auto-generated method stub
					LogUtil.i(TAG,"云端getMsgCode方法返回"+object.toString());
                    identifyCodeFromCloud = object.toString();
				}

				@Override
				public void onFailure(int statusCode, String msg) {
					// TODO Auto-generated method stub
					showToast("访问云端usertest方法失败:" +statusCode+ msg);
					switch (statusCode) {
					case 9010:
						showToast(getString(R.string.no_network));
						break;
					default:
						break;
					}
				}
			});
		}
	
		private void getIdentifyCodeForResetPassword(String phoneNumber){
			BmobUser.resetPasswordByPhone(this, phoneNumber, new ResetPasswordListener() {

				@Override
				public void onSuccess() {
					// TODO Auto-generated method stub
					LogUtil.i(TAG,"获取验证码成功。");
				}

				@Override
				public void onFailure(int arg0, String arg1) {
					// TODO Auto-generated method stub
					LogUtil.i(TAG,"获取验证码失败。");
				}
			});
		}
		
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.identify_commit:
			//commit register code
		    if(identifyType!=null&&identifyType.equals("find_password")){
		        //findback code
		    	identifyCodeFromMsg = identifyCodeInput.getText().toString().trim();
//		    	if(!identifyCodeFromMsg.equals(identifyCodeFromCloud)){
//		    		showToast(getString(R.string.identify_code_not_match));
//		    		return;
//		    	}
		    	Bundle bundle = new Bundle();
//		    	if(mUser!=null){
//		    		bundle.putSerializable("user", mUser);
//		    	}
		    	if(!TextUtils.isEmpty(identifyCodeFromMsg)){
		    		bundle.putString("identify_code", identifyCodeFromMsg);
		    		bundle.putString("phone", phoneNumer);
		    		redictTo(mContext, ModifyPassWordActivity.class, bundle);
                    finish();
		    	}else{
		    		showToast(getString(R.string.identify_input_hint));
		    		return;
		    	}
		        
		        
		    }else{
		        //register code
		    	identifyCodeFromMsg = identifyCodeInput.getText().toString().trim();
		    	if(!identifyCodeFromMsg.equals(identifyCodeFromCloud)){
		    		showToast(getString(R.string.identify_code_not_match));
		    		return;
		    	}
		    	
				User user = new User();
				user.setUsername(phoneNumer);
				user.setPassword(password);
//				user.setInstallId(BmobInstallation.getInstallationId(mContext));
                user.setMidfielder(0);
                user.setBe_good(0);
                user.setGames(0);
                user.setGoals(0);
                user.setAssists(0);
                user.setGamesTotal(0);
                user.setGoalsTotal(0);
                user.setAssistsTotal(0);
				user.signUp(mContext, new SaveListener() {
					
					@Override
					public void onSuccess() {
						// TODO Auto-generated method stub
						showToast(getString(R.string.register_success));
                        // 根据球队验证码加入对应的球队
                        addTeam(inviteCode);
                        // 百度推送
                        PushManager.startWork(getApplicationContext(), PushConstants.LOGIN_TYPE_API_KEY, PushHelper2.API_KEY);
					}
					
					@Override
					public void onFailure(int statusCode, String arg1) {
						// TODO Auto-generated method stub
						showToast(getString(R.string.register_failed));
						LogUtil.i(TAG,"register failed:"+statusCode+arg1);
						switch (statusCode) {
						case 9010:
							showToast(getString(R.string.no_network));
							break;
						case 202:
							showToast(getString(R.string.user_already_registered));
							break;
						default:
							break;
						}
					}
				});
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
		if(timer!=null)
			timer.cancel();
	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
		if(timer!=null){
			timer.cancel();
		}
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		identifyTimeTips = (TextView)contentView.findViewById(R.id.identify_input_tips);
		identifyCodeInput = (EditText)contentView.findViewById(R.id.identify_input_content);
		identifyCommit = (Button)contentView.findViewById(R.id.identify_commit);
		identifyCommit.setOnClickListener(this);
	}

	class TimeCountDown extends CountDownTimer{

		public TimeCountDown(long millisInFuture, long countDownInterval) {
			super(millisInFuture, countDownInterval);
			// TODO Auto-generated constructor stub
		}

		@Override
		public void onTick(long millisUntilFinished) {
			// TODO Auto-generated method stub
			identifyTimeTips.setText("验证码("+millisUntilFinished/1000+")");
		}

		@Override
		public void onFinish() {
			// TODO Auto-generated method stub
			identifyCodeFromMsg = identifyCodeInput.getText().toString().trim();
			LogUtil.i("IdentifyActivity",identifyCodeFromCloud+".."+identifyCodeFromMsg);
	    	if(!identifyCodeFromMsg.equals(identifyCodeFromCloud)){
	    		showToast(getString(R.string.request_identify_code));
	    		if(!TextUtils.isEmpty(identifyType)&&identifyType.equals("find_password")){
//	    			getIdentifyCodeForResetPassword(phoneNumer);
                    getIdentifyCodeForRegister(phoneNumer);
                }else{
	    			getIdentifyCodeForRegister(phoneNumer);
	    		}
				if(timer!=null){
					timer.cancel();
					timer.start();
				}
	    	}
			
		}
		
	}

    private void addTeam(String team_regCode){
        if(TextUtils.isEmpty(team_regCode)){
            finish();
            redictTo(mContext, MainActivity.class, null);
            return;
        }
        BmobQuery<Team> query = new BmobQuery<Team>();
        query.addWhereEqualTo("reg_code", team_regCode);
        query.findObjects(this, new FindListener<Team>() {
            @Override
            public void onSuccess(List<Team> teams) {
                if(teams.size()>0){
                    Team team = teams.get(0);
                    BmobRelation bmobRelation = new BmobRelation();
                    bmobRelation.add(getUser());
                    team.setFootballer(bmobRelation);
                    team.update(IdentifyingActivity.this, new UpdateListener() {
                        @Override
                        public void onSuccess() {

                        }

                        @Override
                        public void onFailure(int i, String s) {

                        }
                    });
                }
                finish();
                redictTo(mContext, MainActivity.class, null);
                finish();
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }
}
